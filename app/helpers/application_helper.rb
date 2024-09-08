# frozen_string_literal: true

module ApplicationHelper
  def by_date_options
    options_for_select([['Último Mês', nil], ['Três Meses', :last_3_months], ['Cinco Meses', :last_5_months]])
  end
end
