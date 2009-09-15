require "test/unit"
require "htmlfilter"

class TestHtmlFilter < Test::Unit::TestCase

  # core tests

  def test_multiton_without_options
    h1 = HtmlFilter.new
    h2 = HtmlFilter.new
    h3 = HtmlFilter.new( :strip_comments => false )
    assert_equal( h1.object_id, h2.object_id )
    assert_not_equal( h1.object_id, h3.object_id )
  end

  def test_multiton_with_options
    h1 = HtmlFilter.new( :strip_comments => false )
    h2 = HtmlFilter.new( :strip_comments => false )
    h3 = HtmlFilter.new
    assert_equal( h1.object_id, h2.object_id )
    assert_not_equal( h1.object_id, h3.object_id )
  end

  def test_strip_single
    hf = HtmlFilter.new
    assert_equal( '"', hf.send(:strip_single,'\"') )
    assert_equal( "\000", hf.send(:strip_single,'\0') )
  end

  # functional tests

  def assert_filter(filtered, original)
    assert_equal(filtered, original.html_filter)
  end

  def test_fix_quotes
    assert_filter '<img src="foo.jpg" />', "<img src=\"foo.jpg />"
  end

  def test_basics
    assert_filter '', ''
    assert_filter 'hello', 'hello'
  end

  def test_balancing_tags
    assert_filter "<b>hello</b>", "<<b>hello</b>"
    assert_filter "<b>hello</b>", "<b>>hello</b>"
    assert_filter "<b>hello</b>", "<b>hello<</b>"
    assert_filter "<b>hello</b>", "<b>hello</b>>"
    assert_filter "", "<>"
  end

  def test_tag_completion
    assert_filter "hello", "hello<b>"
    assert_filter "<b>hello</b>", "<b>hello"
    assert_filter "hello<b>world</b>", "hello<b>world"
    assert_filter "hello", "hello</b>"
    assert_filter "hello", "hello<b/>"
    assert_filter "hello<b>world</b>", "hello<b/>world"
    assert_filter "<b><b><b>hello</b></b></b>", "<b><b><b>hello"
    assert_filter "", "</b><b>"
  end

  def test_end_slashes
    assert_filter '<img />', '<img>'
    assert_filter '<img />', '<img/>'
    assert_filter '', '<b/></b>'
  end

end