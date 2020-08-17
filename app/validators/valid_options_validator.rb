# Adds the option :valid_options for ActiveModel validates method
#
# Usage within an ActiveModel:
#   validates :foo, valid_options: true
#
# With this set, for the form to be valid `form.foo` must return:
#  - an array containing only keys from `form.options`
#
# To add a custom message:
#   validates :foo, valid_options: { message: "My custom message" }
#
class ValidOptionsValidator < ActiveModel::EachValidator
  def validate_each(form, attribute, value)
    return if value.blank?

    mismatch = mismatching(value, form.options)

    unless mismatch.empty?
      form.errors[attribute] << (options[:message] || I18n.t(".activemodel.errors.validators.valid_options.message"))
    end
  end

  def mismatching(content, options)
    return [content] unless content.is_a?(Array)

    content.map(&:to_sym) - options.map(&:to_sym)
  end
end
