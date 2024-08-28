class OutreachActivityImageUploader < CarrierWave::Uploader::Base
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored:
  def store_dir
    Rails.root.join('storage/uploads/outreach_activity_images')
  end

  # Add an allowlist of extensions which are allowed to be uploaded.
  def extension_allowlist
    %w(jpg jpeg png gif zip)
  end
end
