class RegistrationsController < Devise::RegistrationsController

  # GET /resource/sign_up
  def new
    build_resource({})
    respond_with self.resource
  end

  def edit
    render :edit
  end

end
