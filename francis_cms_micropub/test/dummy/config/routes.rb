Rails.application.routes.draw do

  mount FrancisCmsMicropub::Engine => "/micropub"
end
