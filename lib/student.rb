require_relative "../config/environment.rb"
require 'pry'

class Student
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  def save
    if self.id
      self.update
    else
      DB[:conn].execute(<<~SQL, self.name, self.grade)
      INSERT INTO students (name, grade)
      VALUES (?, ?);
      SQL
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    DB[:conn].execute(<<~SQL, self.name, self.grade, self.id)
    UPDATE students SET name = ?, grade = ? WHERE id = ?;
    SQL
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    Student.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    row = DB[:conn].execute(<<~SQL, name)[0]
    SELECT * FROM students WHERE name = ?;
    SQL
    self.new_from_db(row)
  end

  def self.create_table
    DB[:conn].execute(<<~SQL)
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    );
    SQL
  end

  def self.drop_table
    DB[:conn].execute(<<~SQL)
    DROP TABLE students;
    SQL
  end


end
