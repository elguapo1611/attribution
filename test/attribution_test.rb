require 'test_helper'

class Address
  include Attribution

  integer :id
  string :street
  string :city
  string :state
  string :zip

  belongs_to :author, :class_name => 'Person'
end

class Person
  include Attribution

  integer :id
  string :first_name
  string :last_name

  has_many :addresses
  has_many :books
end

class Book
  include Attribution

  integer :id
  string :title
  decimal :price
  date :published_on
  boolean :ebook_available
  boolean :used
  float :shipping_weight
  time :created_at
  time :updated_at
  time_zone :time_zone
  array :numbers
  hash_attr :location

  has_many :chapters
  has_many :readers

  def self.find(*args)
  end
end

class Reader
  include Attribution

  integer :id

  def self.all(query = {})
    query
  end

end

class Chapter
  include Attribution

  integer :id
  integer :number, :required => true, :doc => "Starts from 1"
  string :title
  integer :page_number

  belongs_to :book
  has_many :pages

  def self.all(*args)
    []
  end
end

class Page
  include Attribution

  integer :id
  integer :page_number

  belongs_to :book
end

class Parent
  include Attribution

  string :foo
end

class Child < Parent
  include Attribution

  string :bar
end

class Grandchild < Child
  include Attribution

  string :baz
end

module Music

end

module Music
  class Album
    include Attribution

    has_many :tracks

    string :artist
    string :title
  end
end

module Music
  class Track
    include Attribution

    belongs_to :album

    integer :number
    string :title
  end
end

class StoreModel
  include Attribution

  autoload_associations false
end

class Product < StoreModel
  has_many :orders
end

class Order < StoreModel
  belongs_to :product
end

class AttributionTest < Test::Unit::TestCase

  def test_create
    data = {
      :id => 1,
      :title => "Rework",
      :price => "22.00",
      :published_on => "March 9, 2010",
      :ebook_available => "yes",
      :used => "no",
      :shipping_weight => "14.4",
      :created_at => "2013-02-20 05:39:45 -0500",
      :updated_at => "2013-02-20T05:40:37-05:00",
      :time_zone => "Eastern Time (US & Canada)",
      :chapters => [
        {
          :number => "1",
          :title => "Introduction",
          :page_number => "1"
        }, {
          :number => "2",
          :title => "Takedowns",
          :page_number => "7"
        }, {
          :number => "3",
          :title => "Go",
          :page_number => "29"
        }
      ]
    }

    book = Book.new(data.to_json)

    assert_equal 1, book.id
    assert_equal "Rework", book.title
    assert_equal BigDecimal.new("22.00"), book.price
    assert_equal BigDecimal, book.price.class
    assert_equal Date.new(2010, 3, 9), book.published_on
    assert_equal true, book.ebook_available
    assert_equal true, book.ebook_available?
    assert_equal false, book.used
    assert_equal false, book.used?
    assert_equal 14.4, book.shipping_weight
    assert_equal Float, book.shipping_weight.class
    assert_equal Time.parse("2013-02-20T05:39:45-05:00"), book.created_at
    assert_equal Time.parse("2013-02-20T05:40:37-05:00"), book.updated_at
    assert_equal ActiveSupport::TimeZone["Eastern Time (US & Canada)"], book.time_zone
    assert_equal 1, book.chapters.first.number
    assert_equal 3, book.chapters.size
    assert_equal ({}), Reader.all
    assert_equal ([['book_id', 1]]), book.readers
    assert_equal ([['book_id', 1], [:name,"julio"]]), book.readers(:name => 'julio')
    assert_equal ([['book_id', 1]]), book.readers # Instance variable caching
    assert_equal book, book.chapters.first.book
  end

  def test_attributes
    chapter = Chapter.new(:number => "1")
    assert_equal [
      { :name => :id, :type => :integer },
      { :name => :number, :type => :integer, :required => true, :doc => "Starts from 1" },
      { :name => :title, :type => :string },
      { :name => :page_number, :type => :integer },
      { :name => :book_id, :type => :integer }
    ], Chapter.attributes
    assert_equal({ :id => nil, :number => 1, :title => nil, :page_number => nil, :book_id => nil }, chapter.to_h)
  end

  def test_date_hash
    book = Book.new(:published_on => { :year => '2013', :month => '03', :day => '17' })
    assert_equal Date.parse('2013-03-17'), book.published_on
  end

  def test_date_hash_just_year
    book = Book.new(:published_on => { :year => '2013', :month => '', :day => '' })
    assert_equal Date.new(2013), book.published_on
  end

  def test_date_hash_just_year_month
    book = Book.new(:published_on => { :year => '2013', :month => '5', :day => '' })
    assert_equal Date.new(2013, 5), book.published_on
  end

  def test_date_hash_empty
    book = Book.new(:published_on => { :year => '', :month => '', :day => '' })
    assert_equal nil, book.published_on
  end

  def test_time_hash
    book = Book.new(:created_at => { :year => '2013', :month => '03', :day => '17', :hour => '07', :min => '30', :sec => '11', :utc_offset => '3600' })
    assert_equal Time.parse('2013-03-17 07:30:11 +01:00'), book.created_at
  end

  def test_time_hash_empty
    book = Book.new(:created_at => { :year => '', :month => '', :day => '', :hour => '', :min => '', :sec => '', :utc_offset => '' })
    assert_equal nil, book.created_at
  end

  def test_time_hash_just_year
    book = Book.new(:created_at => { :year => '2013' })
    assert_equal Time.parse('2013-01-01 00:00:00'), book.created_at
  end

  def test_time_hash_just_year_month
    book = Book.new(:created_at => { :year => '2013', :month => '03' })
    assert_equal Time.parse('2013-03-01 00:00:00'), book.created_at
  end

  def test_time_hash_just_year_month_day
    book = Book.new(:created_at => { :year => '2013', :month => '03', :day => '17' })
    assert_equal Time.parse('2013-03-17 00:00:00'), book.created_at
  end

  def test_nothing
    book = Book.new
    assert_equal nil, book.id
    assert_equal nil, book.title
    assert_equal nil, book.price
    assert_equal nil, book.published_on
    assert_equal nil, book.ebook_available
    assert_equal nil, book.used
    assert_equal nil, book.shipping_weight
    assert_equal nil, book.created_at
    assert_equal nil, book.time_zone
    assert_equal nil, book.numbers
    assert_equal nil, book.location
    assert_equal [], book.chapters
  end

  def test_nil
    book = Book.new(
      :id => nil,
      :title => nil,
      :price => nil,
      :published_on => nil,
      :ebook_available => nil,
      :used => nil,
      :shipping_weight => nil,
      :created_at => nil,
      :time_zone => nil,
      :numbers => nil,
      :location => nil
    )
    assert_equal nil, book.id
    assert_equal nil, book.title
    assert_equal nil, book.price
    assert_equal nil, book.published_on
    assert_equal nil, book.ebook_available
    assert_equal nil, book.used
    assert_equal nil, book.shipping_weight
    assert_equal nil, book.created_at
    assert_equal nil, book.time_zone
    assert_equal [], book.numbers
    assert_equal({}, book.location)
    assert_equal [], book.chapters
  end

  def test_array_with_scalar
    book = Book.new(:numbers => 42)
    assert_equal [42], book.numbers
  end

  def test_hash_attr
    book = Book.new(:location => { :lat => 39.27983915, :lon => -76.60873889 })
    assert_equal  39.27983915, book.location[:lat]
    assert_equal -76.60873889, book.location[:lon]
  end

  def test_attributes_setter
    book = Book.new
    book.attributes = { :title => "Whatever", :price => 50 }
    assert_equal "Whatever", book.title
    assert_equal BigDecimal.new("50"), book.price
    assert_equal nil, book.id
  end

  def test_has_many_setter_with_hash
    assert_equal(["test"], Book.new("chapters" => { "0" => { "title" => "test" }}).chapters.map(&:title))
  end

  def test_non_attribute_values_should_be_ignored_by_the_initializer
    book = Book.new(foo: 'bar')
    assert_equal nil, book.instance_variable_get('@foo')
  end

  def test_to_json_should_only_include_attibutes
    book = Book.new(:id => 1, :foo => 'bar')
    assert_equal nil, JSON.parse(book.to_json)['foo']
    assert JSON.parse(book.to_json).key?('title'), 'to_json sohuld include attributes that have no value assigned to them'
  end

  def test_has_many_association_name
    person = Person.new(addresses: [{id: 1}])
    assert_equal [1], person.addresses.map(&:id)
  end

  def test_attribute_inheritence
    assert_equal [:foo, :bar, :baz], Grandchild.attribute_names
  end

  def test_namespaced_belongs_to
    track = Music::Track.new(:number => 1, :title => "Elevator Music", :album => { :artist => "Beck", :title => "The Information" })
    assert_equal "Beck", track.album.artist
  end

  def test_namespaced_has_many
    album = Music::Album.new(:artist => "Beck", :title => "The Information", :tracks => [ { :number => 1, :title => "Elevator Music" } ])
    assert_equal "Elevator Music", album.tracks.first.title
  end

  def test_autoload_belongs_to_associations
    chapter = Chapter.new(:book_id => 42)
    Book.expects(:find).with(42)
    chapter.book
  end

  def test_autoload_has_many_associations
    book = Book.new(:id => 42)
    Chapter.expects(:all).with("book_id" => 42)
    book.chapters
  end

  def test_disabled_autoload_belongs_to_associations
    order = Order.new
    Product.expects(:find).never
    order.product
  end

  def test_disabled_autoload_has_many_associations
    product = Product.new
    Order.expects(:all).never
    assert_equal [], product.orders
  end

  def test_associations
    assert_equal [
      { :name => :book, :type => :belongs_to },
      { :name => :pages, :type => :has_many }
    ], Chapter.associations
  end

end
