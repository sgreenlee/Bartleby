describe 'AssocOptions' do
  describe 'Bartleby::BelongsToOptions' do
    it 'provides defaults' do
      options = Bartleby::BelongsToOptions.new('company')

      expect(options.foreign_key).to eq(:company_id)
      expect(options.class_name).to eq('Company')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = Bartleby::BelongsToOptions.new('manager',
                                     foreign_key: :manager_id,
                                     class_name: 'Manager',
                                     primary_key: :manager_id
      )

      expect(options.foreign_key).to eq(:manager_id)
      expect(options.class_name).to eq('Manager')
      expect(options.primary_key).to eq(:manager_id)
    end
  end

  describe 'Bartleby::HasManyOptions' do
    it 'provides defaults' do
      options = Bartleby::HasManyOptions.new('employees', 'Manager')

      expect(options.foreign_key).to eq(:manager_id)
      expect(options.class_name).to eq('Employee')
      expect(options.primary_key).to eq(:id)
    end

    it 'allows overrides' do
      options = Bartleby::HasManyOptions.new('employees', 'Manager',
                                   foreign_key: :manager_id,
                                   class_name: 'Donut',
                                   primary_key: :manager_id
      )

      expect(options.foreign_key).to eq(:manager_id)
      expect(options.class_name).to eq('Donut')
      expect(options.primary_key).to eq(:manager_id)
    end
  end

  describe 'AssocOptions' do
    before(:all) do
      class Employee < Bartleby::Objectifier
        self.finalize!
      end

      class Manager < Bartleby::Objectifier
        self.table_name = 'managers'
        self.finalize!
      end
    end

    it '#model_class returns class of associated object' do
      options = Bartleby::BelongsToOptions.new('manager')
      expect(options.model_class).to eq(Manager)

      options = Bartleby::HasManyOptions.new('employees', 'Manager')
      expect(options.model_class).to eq(Employee)
    end

    it '#table_name returns table name of associated object' do
      options = Bartleby::BelongsToOptions.new('manager')
      expect(options.table_name).to eq('managers')

      options = Bartleby::HasManyOptions.new('employees', 'Manager')
      expect(options.table_name).to eq('employees')
    end
  end
end

describe 'Associatable' do
  before(:each) { Bartleby::Connection.reset }
  after(:each) { Bartleby::Connection.reset }

  before(:all) do
    class Employee < Bartleby::Objectifier
      belongs_to :manager, foreign_key: :manager_id
      self.finalize!
    end

    class Manager < Bartleby::Objectifier
      self.table_name = 'managers'

      has_many :employees, foreign_key: :manager_id
      belongs_to :company, class_name: "Company"

      self.finalize!
    end

    class Company < Bartleby::Objectifier
      self.table_name = "companies"
      has_many :managers
      self.finalize!
    end
  end

  describe '#belongs_to' do
    let(:john) { Employee.find(1) }
    let(:peter) { Manager.find(1) }

    it 'fetches `manager` from `Employee` correctly' do
      expect(john).to respond_to(:manager)
      manager = john.manager

      expect(manager).to be_instance_of(Manager)
      expect(manager.fname).to eq('Peter')
    end

    it 'fetches `company` from `Manager` correctly' do
      expect(peter).to respond_to(:company)
      company = peter.company

      expect(company).to be_instance_of(Company)
      expect(company.name).to eq('ACME')
    end

    it 'returns nil if no associated object' do
      stray_employee = Employee.find(5)
      expect(stray_employee.manager).to eq(nil)
    end
  end

  describe '#has_many' do
    let(:adam) { Manager.find(3) }
    let(:adam_company) { Company.find(2) }

    it 'fetches `employees` from `Manager`' do
      expect(adam).to respond_to(:employees)
      employees = adam.employees

      expect(employees.length).to eq(2)

      expected_employee_names = ["James Garfield",  "Otto Von Bismark"]
      2.times do |i|
        employee = employees[i]

        expect(employee).to be_instance_of(Employee)
        expect(employee.name).to eq(expected_employee_names[i])
      end
    end

    it 'fetches `managers` from `Company`' do
      expect(adam_company).to respond_to(:managers)
      managers = adam_company.managers

      expect(managers.length).to eq(1)
      expect(managers[0]).to be_instance_of(Manager)
      expect(managers[0].fname).to eq('Adam')
    end

    it 'returns an empty array if no associated items' do
      employeeless_manager = Manager.find(4)
      expect(employeeless_manager.employees).to eq([])
    end
  end

  describe '::assoc_options' do
    it 'defaults to empty hash' do
      class TempClass < Bartleby::Objectifier
      end

      expect(TempClass.assoc_options).to eq({})
    end

    it 'stores `belongs_to` options' do
      employee_assoc_options = Employee.assoc_options
      manager_options = employee_assoc_options[:manager]

      expect(manager_options).to be_instance_of(Bartleby::BelongsToOptions)
      expect(manager_options.foreign_key).to eq(:manager_id)
      expect(manager_options.class_name).to eq('Manager')
      expect(manager_options.primary_key).to eq(:id)
    end

    it 'stores options separately for each class' do
      expect(Employee.assoc_options).to have_key(:manager)
      expect(Manager.assoc_options).to_not have_key(:manager)

      expect(Manager.assoc_options).to have_key(:company)
      expect(Employee.assoc_options).to_not have_key(:company)
    end
  end

  describe '#has_one_through' do
    before(:all) do
      class Employee
        has_one_through :company, :manager, :company
        self.finalize!
      end
    end

    let(:employee) { Employee.find(1) }

    it 'adds getter method' do
      expect(employee).to respond_to(:company)
    end

    it 'fetches associated `company` for a `Employee`' do
      company = employee.company

      expect(company).to be_instance_of(Company)
      expect(company.name).to eq('ACME')
    end
  end
end
