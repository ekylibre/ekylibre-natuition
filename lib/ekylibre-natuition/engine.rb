module EkylibreNatuition
  class Engine < ::Rails::Engine
    initializer 'ekylibre-natuition.assets.precompile' do |app|
      app.config.assets.precompile += %w[integrations/natuition.png]
    end

    initializer 'ekylibre-natuition.i18n' do |app|
      app.config.i18n.load_path += Dir[EkylibreNatuition::Engine.root.join('config', 'locales', '**', '*.yml')]
    end

    initializer 'ekylibre-natuition.extend_toolbar' do |_app|
      Ekylibre::View::Addon.add(:extensions_content_top, 'backend/natuition/sync_natuition_toolbar', to: 'backend/ride_sets#index')
    end
  end
end
