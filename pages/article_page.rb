require_relative 'main_menu'

class ArticlePage < WebPage
  validates :title, pattern: /\ADemo web application - Article\z/
  validates :url, pattern: /\/articles\/\d+\/?\z/

  add_field_locator :comment_field, 'comment_body'
  add_button_locator :add_comment_button, 'Create comment'
  add_locator :commenter_name, xpath: ".//p[contains(.,'Commenter:')]"
  add_locator :comment_text, xpath: ".//p[contains(.,'Comment:')]"
  add_locator :destroy_comment, lambda{|comment| {xpath: ".//p[contains(.,'#{comment}')]/following-sibling::p/a[.='Destroy Comment']"} }
  add_locator :article_button, lambda{|title| {xpath: "//a[contains(.,'#{title}')]"} }
  include MainMenu

  def fill_form(body: nil)
    log.info "Fill in Add Comment form with body: #{body}"
    fill_in(field_locator(:comment_field), with: body) unless body.nil?
  end

  def submit_form
    log.info "Submit Add Comment form"
    click_button(button_locator :add_comment_button)
  end

  def comment_data
    {
        commenter: find(locator :commenter_name).text.gsub(/Commenter: /, ''),
        comment: find(locator :comment_text).text.gsub(/Comment: /, '')
    }
  end

  def click_article_button(text)
    log.info "Open '#{text}' article"
    find(apply(locator(:article_button),(text))).click
  end

  def destroy_comment(comment_text,confirmation = true)
    log.info "Destroy comment  '#{comment_text}' on article page with confirmation: '#{confirmation}'"
    destroy = -> {find(apply(locator(:destroy_comment),(comment_text))).click}
    if confirmation
      accept_js_confirmation do
        destroy.call
      end
    else
      dismiss_js_confirmation do
        destroy.call
      end
    end

  end
end