require 'helper'

class TestRaLoSe < Test::Unit::TestCase

  def test_returns_no_lines_when_passed_a_file
    query  = 'nothing to see here'
    output = `bundle exec ralose '#{query}' test/fixtures/sample.log`

    expected_output = %{}
    assert_equal expected_output, output
  end

  def test_returns_no_lines_when_piped_a_file
    query  = 'nothing to see here'
    output = `cat test/fixtures/sample.log | bundle exec ralose '#{query}'`

    expected_output = %{}
    assert_equal expected_output, output
  end

  def test_returns_the_matching_request_when_passed_a_file
    query  = 'GET "/blog_posts/1"'
    output = `bundle exec ralose '#{query}' test/fixtures/sample.log`

    expected_output = %{[c61f4934-2c2a-4042-933d-3ded6b5980f4] Started \e[31mGET "/blog_posts/1"\e[0m for 127.0.0.1 at 2018-05-25 11:36:33 +0100\n[c61f4934-2c2a-4042-933d-3ded6b5980f4] Processing by BlogPostsController#show as HTML\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   Parameters: {"id"=>"1"}\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   \e[1m\e[36mBlogPost Load (0.2ms)\e[0m  \e[1m\e[34mSELECT  "blog_posts".* FROM "blog_posts" WHERE "blog_posts"."id" = ? LIMIT ?\e[0m  [["id", 1], ["LIMIT", 1]]\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   ↳ app/controllers/blog_posts_controller.rb:67\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   Rendering blog_posts/show.html.erb within layouts/application\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   Rendered blog_posts/show.html.erb within layouts/application (0.6ms)\n[c61f4934-2c2a-4042-933d-3ded6b5980f4] Completed 200 OK in 31ms (Views: 25.0ms | ActiveRecord: 0.2ms)\n\n\n}
    assert_equal expected_output, output
  end

  def test_returns_the_matching_request_when_piped_a_file
    query  = 'GET "/blog_posts/1"'
    output = `cat test/fixtures/sample.log | bundle exec ralose '#{query}'`

    expected_output = %{[c61f4934-2c2a-4042-933d-3ded6b5980f4] Started \e[31mGET "/blog_posts/1"\e[0m for 127.0.0.1 at 2018-05-25 11:36:33 +0100\n[c61f4934-2c2a-4042-933d-3ded6b5980f4] Processing by BlogPostsController#show as HTML\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   Parameters: {"id"=>"1"}\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   \e[1m\e[36mBlogPost Load (0.2ms)\e[0m  \e[1m\e[34mSELECT  "blog_posts".* FROM "blog_posts" WHERE "blog_posts"."id" = ? LIMIT ?\e[0m  [["id", 1], ["LIMIT", 1]]\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   ↳ app/controllers/blog_posts_controller.rb:67\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   Rendering blog_posts/show.html.erb within layouts/application\n[c61f4934-2c2a-4042-933d-3ded6b5980f4]   Rendered blog_posts/show.html.erb within layouts/application (0.6ms)\n[c61f4934-2c2a-4042-933d-3ded6b5980f4] Completed 200 OK in 31ms (Views: 25.0ms | ActiveRecord: 0.2ms)\n\n\n}
    assert_equal expected_output, output
  end

  def test_colors_the_matching_string
    query  = 'GET "/blog_posts/2"'
    output = `bundle exec ralose '#{query}' test/fixtures/sample.log`

    expected_output = %{\e[31mGET "/blog_posts/2"\e[0m}
    assert output.include?(expected_output)
  end

  def test_does_not_color_the_matching_string
    query  = 'GET "/blog_posts/2"'
    output = `bundle exec ralose --no-color '#{query}' test/fixtures/sample.log`

    unexpected_output = %{\e[31mGET "/blog_posts/2"\e[0m}
    expected_output   = %{GET "/blog_posts/2"}

    assert output.include?(expected_output)
    assert !output.include?(unexpected_output)
  end

end
