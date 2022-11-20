class Api::V0::CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show update destroy ]

  # GET /companies
  def index
    @companies = Company.all

    render json: @companies
  end

  # GET /companies/1
  def show   
    @company = Company.find(params[:id])
    
    # get pdf_files urls (blank array if none attached)
    url_array = []                    
    for pdf in @company.pdf_files   # get array of URLs for each file
      url_array.push(url_for(pdf))  # url_array = ['url01', 'url02', ...]
    end

    # append url_array to company
    company_hash = @company.as_json                               # convert company into hash
    company_hash.store('number_files', @company.pdf_files.length) # append number of URLs to company_hash
    company_hash.store('urls', url_array)                    # append url_array to company_hash

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
end
