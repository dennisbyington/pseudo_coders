class Api::V0::CompaniesController < ApplicationController
  
  before_action :set_company, only: %i[ show update destroy ]
  
  before_action do
    ActiveStorage::Current.host = request.base_url
  end
  # FIXME is this what's causing hangups?
  # DEPRECATION WARNING: ActiveStorage::Current.host= is deprecated, instead use ActiveStorage::Current.url_options= (called from block in <class:CompaniesController>
  # https://stackoverflow.com/questions/71860516/activestoragecurrent-host-is-deprecated-how-can-i-use-activestoragecurrent


  # GET /companies/bbox/company_id/blob_id
  def bbox
    @company = Company.find(params[:company_id])

    # get url from blob_id
    # TODO ? add error checking here before passing url to get_bboxes()
    url = @company.pdf_files.blobs.find_by_id(params[:blob_id]).url
    
    # get bboxes
    # FIXME hanging in here every once in a while.  WHY?
    bboxes = get_bboxes(url)

    # render the array returned from get_bboxes
    render json: bboxes
  end

  # GET /companies
  def index
    @companies = Company.all

    render json: @companies
  end

  # GET /companies/1
  def show   
    @company = Company.find(params[:id])
    
    # --------------------------------------------------
    # old - remove after front end is updated to accept new array
    # --------------------------------------------------
    # get pdf_files urls (blank array if none attached)
    # url_array = []                    
    # for pdf in @company.pdf_files   # get array of URLs for each file
    #   url_array.push(url_for(pdf))  # url_array = ['url01', 'url02', ...]
    # end
    # --------------------------------------------------
    
    url_array = []           
    for pdf in @company.pdf_files                   # make array of blob_ids & URLs for each file
      url_array.push([pdf.blob_id, url_for(pdf)])   # url_array = [[blob_id, 'url01'], [blob_id, 'url02'], ...]
    end

    # append url_array to company
    company_hash = @company.as_json                               # convert company into hash
    company_hash.store('number_files', @company.pdf_files.length) # append number of URLs to company_hash
    company_hash.store('urls', url_array)                         # append url_array to company_hash

    render json: company_hash
  end

  # POST /companies
  def create
    @company = Company.new(company_params)

    if @company.save
      render json: @company, status: :created, location: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/1
  def update
    if @company.update(company_params)
      render json: @company
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # DELETE /companies/1
  def destroy
    @company.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = Company.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.require(:company).permit(:name, pdf_files: [])
    end

    def get_bboxes(url)

      # check if valid url  
      # TODO need to move this to bbox?
      # TODO is this causing hangups every once in a while?
      unless URI.open(url).status == ["200", "OK"]
        # TODO refactor=> how to send back "bad" response if invalid url
        puts "Error - bad file path"  
        exit
      end

      # system call to pdftotext - outputs xml data to bbox-back/xml-output.xml
      system("pdftotext -bbox-layout #{url} xml-output.xml")
      
      # open output file, get xml data, close and delete file
      f = File.open("xml-output.xml")
      doc = Nokogiri::XML(f)
      f.close
      File.delete("xml-output.xml") if File.exist?("xml-output.xml")

      # array to hold pages->flows->coords
      bboxes = []   # bboxes[page#][flow#] = [xMin, yMin, xMax, yMax]

      # temp arrays to hold values for each block within a flow
      xmins, ymins, xmaxs, ymaxs = [], [], [], []

      # loop through each page->flow->block
      # for each page
      doc.css("page").each_with_index do |page, page_num|
        bboxes.push([])   # append a new "page" entry to bboxes

        # for each flow
        page.css("flow").each_with_index do |flow, flow_num|
          bboxes[page_num].push([])   # append a new "flow" entry to bboxes[current page]

          # for each block 
          flow.css("block").each_with_index do |block, block_num|
            xmins.push(block["xMin"].to_f)    # append xmin to xmins (convert to float)
            ymins.push(block["yMin"].to_f)    # append ymin to ymins (convert to float)
            xmaxs.push(block["xMax"].to_f)    # append xmax to xmaxs (convert to float)
            ymaxs.push(block["yMax"].to_f)    # append ymax to ymaxs (convert to float)
          end # for each block

          # get min/max of each flow (xmin, ymin, xmax, ymax)
          xmin = xmins.min
          ymin = ymins.min
          xmax = xmaxs.max
          ymax = ymaxs.max
          
          # append flow min/max values to bboxes[current page][current flow]
          bboxes[page_num][flow_num].push(xmin)
          bboxes[page_num][flow_num].push(ymin)
          bboxes[page_num][flow_num].push(xmax)
          bboxes[page_num][flow_num].push(ymax)
          
          # clear arrays & continue (xmin, ymin, xmax, ymax)
          xmins.clear()
          ymins.clear()
          xmaxs.clear()
          ymaxs.clear()
        end # for each flow
      end # for each page

      return bboxes
    end  # get_bboxes()

end
