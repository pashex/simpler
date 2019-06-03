require_relative 'config/environment'

use Simpler::AppLogger, logdev: Simpler.root.join('log/app.log')
run Simpler.application
