class Api::V0::CompaniesController < ApplicationController
  before_action :set_company, only: %i[ show update destroy ]

  # GET /companies
  def index
    @companies = Company.all

    render json: @companies
  end

  # GET /companies/1
  # *** this is working for 1 pdf only ***
  def show
    # ----------------------
    # render json: @company
    # ----------------------
    @company = Company.find(params[:id])
    
    if @company.pdf_file.attached?
      render json: @company.as_json.merge(pdf_file_path: url_for(@company.pdf_file))
    else
      render json: @company.as_json
    end
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
      params.require(:company).permit(:name, :pdf_file)
      # params.require(:company).permit(:name, pdf_files: [])
    end
end
