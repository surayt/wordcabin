module I18n
  def icon_t(icon, text)
    text = I18n.t(text)
    if I18n.locale == :ar
      "#{text}&nbsp;<i class=\"fa fa-#{icon}\"></i>"
    else
      "<i class=\"fa fa-#{icon}\"></i>&nbsp;#{text}"
    end
  end
  
  module_function :icon_t
end
