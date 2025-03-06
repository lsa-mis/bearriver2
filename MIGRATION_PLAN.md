# Migration Plan: Rails 7.2.2 and Propshaft

This document outlines the steps to migrate your application from Rails 7.1.3 with sassc-rails to Rails 7.2.2 with propshaft.

## Steps to Complete the Migration

1. **Update Dependencies**

   ```bash
   bundle install
   ```

2. **Update Node Packages (if needed)**

   ```bash
   yarn install
   ```

3. **Run Rails Update Tasks**

   ```bash
   bin/rails app:update
   ```

   This will guide you through updating configuration files for Rails 7.2.2. Be careful to review each change and only accept those that make sense for your application.

4. **Handle Migration Errors**

   When running migrations, you might encounter errors related to strong_migrations. For Rails internal migrations (like Active Storage migrations), you can safely bypass these checks by wrapping the migration code in a `safety_assured` block:

   ```ruby
   def up
     safety_assured do
       # migration code here
     end
   end
   ```

   This is particularly important for migrations that add NOT NULL constraints or change column types.

   **Note:** The following Active Storage migrations have been updated with `safety_assured` blocks:
   - `20250306222813_add_service_name_to_active_storage_blobs.active_storage.rb`
   - `20250306222814_create_active_storage_variant_records.active_storage.rb` (also fixed a regex issue with primary key type detection)
   - `20250306222815_remove_not_null_on_active_storage_blobs_checksum.active_storage.rb`
   - `20200116171316_create_active_storage_tables.active_storage.rb`

   The `CreateActiveStorageVariantRecords` migration had an additional issue with primary key type detection. The original code used a regex that didn't match the PostgreSQL primary key format. This has been fixed by implementing a more robust method to determine the primary key type.

   After updating these files, run the migrations:

   ```bash
   bin/rails db:migrate
   ```

5. **Configure ActiveAdmin for Propshaft**

   ActiveAdmin requires special configuration to work with propshaft. The following files have been created or updated:

   - `config/initializers/assets.rb`: Added ActiveAdmin asset paths
   - `config/initializers/active_admin.rb`: Updated to include propshaft configuration
   - `app/assets/config/manifest.js`: Added ActiveAdmin assets
   - `app/assets/stylesheets/active_admin.css`: Created to import ActiveAdmin styles
   - `app/assets/javascripts/active_admin.js`: Created to import ActiveAdmin scripts

   These changes ensure that ActiveAdmin's assets are properly loaded by propshaft.

   **Note:** We've added the propshaft configuration directly to the existing ActiveAdmin initializer rather than creating a separate initializer, as this avoids conflicts between multiple initializers.

6. **Precompile Assets**

   ```bash
   bin/rails assets:clobber
   bin/rails assets:precompile
   ```

7. **Test in Development**

   Start your Rails server and verify that all assets are loading correctly:

   ```bash
   bin/rails server
   ```

   Check your browser console for any asset loading errors.

8. **Troubleshooting Common Issues**

   - **Missing Assets**: If some assets are missing, check that they're properly referenced in your manifest.js file
   - **Font Issues**: If using custom fonts, ensure they're properly added to the asset paths in config/initializers/assets.rb
   - **CSS URL References**: Propshaft handles asset references in CSS differently than Sprockets. If you have url() references in your CSS, they may need to be updated.
   - **ActiveAdmin Issues**: If ActiveAdmin still has asset issues, try running `bin/rails assets:clobber` and then `bin/rails assets:precompile` again. You may also need to restart your server.

9. **Update CI/CD Pipeline**

   If you have a CI/CD pipeline, make sure to update any asset compilation steps to work with propshaft.

## Key Differences Between sassc-rails and propshaft

1. **Simpler Asset Pipeline**: Propshaft doesn't do bundling or transpiling - it focuses on digesting and serving assets.

2. **No Built-in Sass Support**: You'll need to use cssbundling-rails or another solution for Sass compilation.

3. **Asset References**: In JavaScript, use `RAILS_ASSET_URL("/path/to/asset")` to reference assets that need digesting.

4. **Performance**: Propshaft is generally faster than Sprockets, especially for larger applications.

## Additional Resources

- [Propshaft GitHub Repository](https://github.com/rails/propshaft)
- [Rails 7.2 Release Notes](https://rubyonrails.org/2024/8/10/Rails-7-2-Better-production-defaults-Dev-containers-new-guides-design-and-more)
- [Strong Migrations Documentation](https://github.com/ankane/strong_migrations)
