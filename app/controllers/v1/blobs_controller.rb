# app/controllers/v1/blobs_controller.rb
module V1
  class BlobsController < ApplicationController
    # GET /v1/blobs
    def index
      @files = FileUploadServiceImpl.get_all_files
      render json: @files
    end

    # POST /v1/blobs
    def create
      file_data = params[:file_upload][:data].tempfile.read

      begin
        @file_upload = FileUploadServiceImpl.upload_file(file_data, params[:file_upload][:data].original_filename)
        render json: @file_upload, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: e.record.errors, status: :unprocessable_entity
      end
    end

    # GET /v1/blobs/:id
    def show
      @file_upload = FileUploadServiceImpl.get_file(params[:id])
      render json: @file_upload
    end

    # DELETE /v1/blobs/:id
    def destroy
      FileUploadServiceImpl.delete_file(params[:id])
      head :no_content
    end
  end
end
