CREATE TABLE employees (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  manager_id INTEGER,

  FOREIGN KEY(manager_id) REFERENCES managers(id)
);

CREATE TABLE managers (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  company_id INTEGER,

  FOREIGN KEY(company_id) REFERENCES companies(id)
);

CREATE TABLE companies (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  companies (id, name)
VALUES
  (1, "ACME"), (2, "Maleant Data Systems");

INSERT INTO
  managers (id, fname, lname, company_id)
VALUES
  (1, "Peter", "Rao", 1),
  (2, "Eliot", "Bradshaw", 1),
  (3, "Adam", "Abdelaziz", 2),
  (4, "Sam", "Greenlee", NULL);

INSERT INTO
  employees (id, name, manager_id)
VALUES
  (1, "John Calhoun", 1),
  (2, "Richard Henry", 2),
  (3, "James Garfield", 3),
  (4, "Otto Von Bismark", 3),
  (5, "Plato", NULL);
