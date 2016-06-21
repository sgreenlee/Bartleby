describe Bartleby::Objectifier do
  before(:each) { Bartleby::Connection.reset }
  after(:each) { Bartleby::Connection.reset }

  context 'before ::finalize!' do
    before(:each) do
      class Employee < Bartleby::Objectifier
      end
    end

    after(:each) do
      Object.send(:remove_const, :Employee)
    end

    describe '::table_name' do
      it 'generates default name' do
        expect(Employee.table_name).to eq('employees')
      end
    end

    describe '::table_name=' do
      it 'sets table name' do
        class Company < Bartleby::Objectifier
          self.table_name = 'companies'
        end

        expect(Company.table_name).to eq('companies')

        Object.send(:remove_const, :Company)
      end
    end

    describe '::columns' do
      it 'returns a list of all column names as symbols' do
        expect(Employee.columns).to eq([:id, :name, :manager_id])
      end

      it 'only queries the DB once' do
        expect(Bartleby::Connection).to(
          receive(:execute2).exactly(1).times.and_call_original)
        3.times { Employee.columns }
      end
    end
  end

  context 'after ::finalize!' do
    before(:all) do
      class Employee < Bartleby::Objectifier
        self.finalize!
      end

      class Manager < Bartleby::Objectifier
        self.finalize!
      end
    end

    after(:all) do
      Object.send(:remove_const, :Employee)
      Object.send(:remove_const, :Manager)
    end

    describe '::finalize!' do
      it 'creates getter methods for each column' do
        e = Employee.new
        expect(e.respond_to? :something).to be false
        expect(e.respond_to? :name).to be true
        expect(e.respond_to? :id).to be true
        expect(e.respond_to? :manager_id).to be true
      end

      it 'creates setter methods for each column' do
        e = Employee.new
        e.name = "Pootie Tang"
        e.id = 209
        e.manager_id = 2
        expect(e.name).to eq 'Pootie Tang'
        expect(e.id).to eq 209
        expect(e.manager_id).to eq 2
      end

      it 'created getter methods read from attributes hash' do
        e = Employee.new
        e.instance_variable_set(:@attributes, {name: "Pootie Tang"})
        expect(e.name).to eq 'Pootie Tang'
      end
    end

    describe '#initialize' do
      it 'calls appropriate setter method for each item in params' do
        # We have to set method expectations on the employee object *before*
        # #initialize gets called, so we use ::alloemployeee to create a
        # blank Employee object first and then call #initialize manually.
        e = Employee.allocate

        expect(e).to receive(:name=).with('Joseph Conrad')
        expect(e).to receive(:id=).with(100)
        expect(e).to receive(:manager_id=).with(4)

        e.send(:initialize, {name: 'Joseph Conrad', id: 100, manager_id: 4})
      end

      it 'throws an error when given an unknown attribute' do
        expect do
          Employee.new(hobby: 'Model airplanes')
        end.to raise_error "unknown attribute 'hobby'"
      end
    end

    describe '::all, ::parse_all' do
      it '::all returns all the rows' do
        employees = Employee.all
        expect(employees.count).to eq(5)
      end

      it '::parse_all turns an array of hashes into objects' do
        hashes = [
          { name: 'employee1', manager_id: 1 },
          { name: 'employee2', manager_id: 2 }
        ]

        employees = Employee.parse_all(hashes)
        expect(employees.length).to eq(2)
        hashes.each_index do |i|
          expect(employees[i].name).to eq(hashes[i][:name])
          expect(employees[i].manager_id).to eq(hashes[i][:manager_id])
        end
      end

      it '::all returns a list of objects, not hashes' do
        employees = Employee.all
        employees.each { |employee| expect(employee).to be_instance_of(Employee) }
      end
    end

    describe '::find' do
      it 'fetches single objects by id' do
        e = Employee.find(1)

        expect(e).to be_instance_of(Employee)
        expect(e.id).to eq(1)
      end

      it 'returns nil if no object has the given id' do
        expect(Employee.find(123)).to be_nil
      end
    end
    #
    # describe '#attribute_values' do
    #   it 'returns array of values' do
    #     employee = Employee.new(id: 123, name: 'employee1', manager_id: 1)
    #
    #     expect(employee.attribute_values).to eq([123, 'employee1', 1])
    #   end
    # end

    describe '#insert' do
      let(:employee) { Employee.new(name: 'Gizmo', manager_id: 1) }

      before(:each) { employee.insert }

      it 'inserts a new record' do
        expect(Employee.all.count).to eq(6)
      end

      it 'sets the id once the new record is saved' do
        expect(employee.id).to eq(Bartleby::Connection.last_insert_row_id)
      end

      it 'creates a new record with the correct values' do
        # pull the employee again
        employee2 = Employee.find(employee.id)

        expect(employee2.name).to eq('Gizmo')
        expect(employee2.manager_id).to eq(1)
      end
    end

    describe '#update' do
      it 'saves updated attributes to the DB' do
        manager = Manager.find(2)

        manager.fname = 'Bruce'
        manager.lname = 'Springstein'
        manager.update

        # pull the manager again
        manager = Manager.find(2)
        expect(manager.fname).to eq('Bruce')
        expect(manager.lname).to eq('Springstein')
      end
    end

    describe '#save' do
      it 'calls #insert when record does not exist' do
        manager = Manager.new
        expect(manager).to receive(:insert)
        manager.save
      end

      it 'calls #update when record already exists' do
        manager = Manager.find(1)
        expect(manager).to receive(:update)
        manager.save
      end
    end
  end
end
