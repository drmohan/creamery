class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  authorize_resource
  
  def index
    @active_employees = Employee.active.alphabetical.paginate(page: params[:active_employees]).per_page(10)
    @inactive_employees = Employee.inactive.alphabetical.paginate(page: params[:inactive_employees]).per_page(10)
  end

  def show
    # get the assignment history for this employee
    @assignments = @employee.assignments.chronological.paginate(page: params[:assignments]).per_page(5)

    # get upcoming shifts for this employee (later)  
    @upcoming_shifts = Shift.for_employee(@employee).for_next_days(14).chronological
  end

  def new
    @employee = Employee.new
    @employee.build_user
  end

  def edit
  end

  def create
    @employee = Employee.new(employee_params)
    
    if @employee.save 
      redirect_to employee_path(@employee), notice: "Successfully created #{@employee.proper_name}."
    else
      render action: 'new'
    end
  end

  def update
    if @employee.update(employee_params) and logged_in? and !current_user.role? :admin
      redirect_to account_path, notice: "Successfully updated #{@employee.proper_name}."
    elsif @employee.update(employee_params) and logged_in? and current_user.role? :admin
      redirect_to employee_path(@employee), notice: "Successfully updated #{@employee.proper_name}."
    else
      render action: 'edit'
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_path, notice: "Successfully removed #{@employee.proper_name} from the AMC system."
  end

  private
  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :ssn, :date_of_birth, :role, :phone, :active, user_attributes: [:id, :email, :password, :password_confirmation])
  end

end