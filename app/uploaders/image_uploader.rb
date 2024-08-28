class ImageUploader < CarrierWave::Uploader::Base
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored:
  def store_dir
    Rails.root.join('storage/uploads/general_images')
  end

  def delete_file(file_name)
    file = store_dir.join(file_name)
    if file.exist?
      file.delete
    end
    true
  end

  # Add an allowlist of extensions which are allowed to be uploaded.
  def extension_allowlist
    %w(*)
  end
end
