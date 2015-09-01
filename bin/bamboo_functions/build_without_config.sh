function build_without_config () {
  echo "  Installing composer dependencies..."
  composer="php -d allow_url_fopen=1 /usr/local/bin/composer.phar"
  $composer validate && $composer install
}
