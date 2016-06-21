describe 'Searchable' do
  before(:each) { Bartleby::Connection.reset }
  after(:each) { Bartleby::Connection.reset }

  before(:all) do
    class Employee < Bartleby::Objectifier
      self.finalize!
    end

    class Manager < Bartleby::Objectifier
      self.table_name = 'managers'
      self.finalize!
    end
  end

  it '#where searches with single criterion' do
    employees = Employee.where(name: 'John Calhoun')
    employee = employees.first

    expect(employees.length).to eq(1)
    expect(employee.name).to eq('John Calhoun')
  end

  it '#where can return multiple objects' do
    managers = Manager.where(company_id: 1)
    expect(managers.length).to eq(2)
  end

  it '#where searches with multiple criteria' do
    managers = Manager.where(fname: 'Peter', company_id: 1)
    expect(managers.length).to eq(1)

    manager = managers[0]
    expect(manager.fname).to eq('Peter')
    expect(manager.company_id).to eq(1)
  end

  it '#where returns [] if nothing matches the criteria' do
    expect(Manager.where(fname: 'Arya', lname: 'Stark')).to eq([])
  end
end
