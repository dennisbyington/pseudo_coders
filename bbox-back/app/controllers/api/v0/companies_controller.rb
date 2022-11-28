class Api::V0::CompaniesController < ApplicationController
  
  before_action :set_company, only: %i[ show update destroy ]
  
  before_action do
    ActiveStorage::Current.url_options = { protocol: request.protocol, host: request.host, port: request.port }
  end
  
  # GET /companies/bbox/company_id/blob_id
  def bbox
    @company = Company.find(params[:company_id])

    # get url from blob_id
    url = @company.pdf_files.blobs.find_by_id(params[:blob_id]).url
    
    # =================================================================================
    # ORIGINAL: get_bboxes
    # =================================================================================
      # bboxes = get_bboxes(url, params[:company_id], params[:blob_id])
      # =================================================================================

    # =================================================================================
    # NEW: get_bboxes
    # =================================================================================
    # get bboxes => catch errors
    begin
      bbox_attempts ||= 1      # keep track of bbox attempts
      puts "****** calling get_bboxes **************************************"
      bboxes = get_bboxes(url, params[:company_id], params[:blob_id])
      
      # check bboxes to verify not empty
      if bboxes == []
        raise 'Error: bboxes empty'
      end

    rescue StandardError => error 
      puts error.message

      if (bbox_attempts += 1) < 5  # retry
        puts "<retrying get_bboxes..>"
        retry # ⤴
      end
    
      # attempts exceeeded, put error message, log error (will render empty list)
      puts "get_bboxes attempts exceeded.  Exiting..."  
      log_errors(error.message, params[:company_id], params[:blob_id])
    
    end # begin
    # =================================================================================
    # /NEW: get_bboxes
    # =================================================================================

    render json: bboxes
  end

  # GET /companies/random/company_id
  def random
    @company = Company.find(params[:company_id])
    
    url_array = []
    pdf_sample = @company.pdf_files.sample(50)      # get random sample of 50 PDFs
    for pdf in pdf_sample                           # make array of blob_ids & URLs for each file
      url_array.push([pdf.blob_id, url_for(pdf)])   # url_array = [[blob_id, 'url01'], [blob_id, 'url02'], ...]
    end

    # append url_array to company
    company_hash = @company.as_json                      # convert company into hash
    company_hash.store('number_files', url_array.length) # append number of URLs (in sample) to company_hash
    company_hash.store('urls', url_array)                # append url_array to company_hash

    render json: company_hash
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

    def get_bboxes(url, company_id, blob_id)
      # NOTE this hangs => added error logging to check
      #   https://ruby-doc.org/stdlib-1.8.7/libdoc/open-uri/rdoc/OpenURI/OpenRead.html
      #   https://docs.ruby-lang.org/en/2.0.0/OpenURI/OpenRead.html

      # array to hold pages->flows->coords
      bboxes = []   # bboxes[page#][flow#] = [xMin, yMin, xMax, yMax]

      # =================================================================================
      # ORIGINAL: read url & create temp.pdf
      # =================================================================================
        # puts "****** reading url ***************************************"
        # open('temp.pdf', 'wb') do |file|
        #   file << URI.open(url).read
        # end
        
        # puts "****** checking temp.pdf ***************************************"
        # unless File.exist?('temp.pdf')
        #   puts "no temp pdf file"
        #   # exit
        # end
        # =================================================================================
    
      # =================================================================================
      # NEW: read url & create temp.pdf (w/ error catch/log)
      # =================================================================================
      # open url & download file to bbox-back/temp.pdf => catch errors 
      begin 
        url_attempts ||= 1      # keep track of url attempts
        temp_pdf_attempts ||= 1 # keep track of temp_pdf attempts

        # download pdf file locally => bbox-back/temp.pdf
        puts "****** reading url ***************************************"
        open('temp.pdf', 'wb') do |file|
        # file << URI.open(url).read
          file << URI.open(url, :read_timeout => 1).read  # TODO is this a good timeout?
        end
        
        # open temp.pdf to verify file created 
        puts "****** checking temp.pdf ***************************************"
        unless File.exist?('temp.pdf')
          puts "no temp pdf file"
          # exit
        end

      # rescue URL timeout
      rescue Net::ReadTimeout => timeout  # Net::ReadTimeout => timeout reading URL
        puts timeout.message
        
        if (url_attempts += 1) < 5  # retry
          puts "<retrying read url...>"
          retry # ⤴
        end

        # attempts exceeeded, put error message, log error, return empty list
        puts "URL read attempts exceeded.  Exiting..."
        log_errors(timeout.message, company_id, blob_id)
        return bboxes  # empty list
        
      # rescue file open error (temp.pdf)
      rescue IOError => io  # I/O Error => temp.pdf does not exist
        puts io.message

        if (temp_pdf_attempts += 1) < 5  # retry
          puts "<retrying open temp.pdf..>"
          retry # ⤴
        end

        # attempts exceeeded, put error message, log error, return empty list
        puts "Open temp.pdf attempts exceeded.  Exiting..."  
        log_errors(io.message, company_id, blob_id)
        return bboxes  # empty list

      end  # begin
      # =================================================================================
      # /NEW: read url & create temp.pdf (w/ error catch/log)
      # =================================================================================


      # =================================================================================
      # ORIGINAL: pdftotext system call
      # =================================================================================
        # puts "****** calling pdftotext **********************************"
        # # system call to pdftotext to get xml data => bbox-back/temp.xml
        # system("pdftotext -bbox-layout temp.pdf temp.xml")
        
        # unless File.exist?('temp.xml')
        #   puts "no temp xml file"
        #   exit
        # end
        # =================================================================================

      # =================================================================================
      # NEW: pdftotext system call (w/ error catch/log)
      # =================================================================================
      # call pdttotext & store results in bbox-back/temp.xml => catch errors 
      begin 
        pdftotext_attempts ||= 1  # keep track of pdftotext attempts
        
        # system call to pdftotext to get xml data => bbox-back/temp.xml
        puts "****** calling pdftotext **********************************"
        system("pdftotext -bbox-layout temp.pdf temp.xml")

        # open temp.xml to verify file created 
        puts "****** checking temp.xml ***************************************"
        unless File.exist?('temp.xml')
          puts "no temp xml file"
          # exit
        end

      # rescue file open error (temp.xml)
      rescue IOError => io  # I/O Error => temp.xml does not exist
        puts io.message

        if (pdftotext_attempts += 1) < 5  # retry
          puts "<retrying pdftotext..>"
          retry # ⤴
        end

        # attempts exceeeded, put error message, log error, return empty list
        puts "Pdftotext / open temp.xml attempts exceeded.  Exiting..."  
        log_errors(io.message, company_id, blob_id)
        return bboxes  # empty list
      
      end  # begin
      # =================================================================================
      # /NEW: pdftotext system call (w/ error catch/log)
      # =================================================================================

      
      # open output file, get xml data, close and delete temp files
      puts "****** calling nokogiri ***********************************"
      f = File.open("temp.xml")
      doc = Nokogiri::XML(f)
      f.close
      File.delete("temp.xml") if File.exist?("temp.xml")
      File.delete("temp.pdf") if File.exist?("temp.pdf")

      
      # temp arrays to hold values for each block within a flow
      xmins, ymins, xmaxs, ymaxs = [], [], [], []


      # loop through each page->flow->block
      puts "****** building bboxes ************************************"
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


    def log_errors(error_message, company_id, blob_id)
      puts "****** logging errors *************************************"
      f = File.open('./log/get_bboxes.log', 'a')
      f.puts(Time.new)
      f.write("company_id: ")
      f.puts(company_id)
      f.write("blob_id: ")
      f.puts(blob_id)
      f.write('error: ')
      f.puts(error_message)
      f.puts('')
      f.close
    end

end
