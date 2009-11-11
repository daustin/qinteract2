# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'development'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# qInteract specific params
QINTERACT_PROJECT_ROOT = '/www-data/www/htdocs/qInteract/data2' #PROJECT ROOT RELAVITVE TO MONGREL SERVER. TO READ INFO ABOUT JOB DATA
PROJECT_ROOT = '/data/www/htdocs/qInteract/data2' #PROJECT ROOT FROM BLADES AND GUAC
SEQUEST_LOGIN = 'proteomics@sequest'
PROJECT_URL_ROOT = 'http://guacamole.itmat.upenn.edu/qInteract/data2' #BASE URL FOR FILE DOWNLOADS AND TPP RELATED LINKS
PROJECT_TMP_ROOT = '/scratch/www/htdocs/qInteract/data2' #SCRATCH ROOT FOR LOCAL PROCESSING ON BLADES
SEQUEST_SSH_PREFIX = 'ssh -n proteomics@sequest'
SEQUEST_SCP_PREFIX = 'scp proteomics@sequest'
QSUB_PREFIX = '/opt/x86_64/torque/bin/qsub '  #PATH TO QSUB
WEBSERVER_ROOT = '/data/www/htdocs' #XINTERACT VAR
WEBSERVER_TMP_ROOT = '/scratch/www/htdocs' #ANOTHER XINTERACT VAR
BIOSTORE_SSH_PREFIX = 'ssh -n fileserver '
BIOSTORE_ROOT = '/export/www-data/www/htdocs/qInteract/data2' #BIOSTORE (FILESERVER) RELATIVE TO FILESERVER FOR QUICK FILESYSTEM ACCESS
PEPXML2HTML_PREFIX = 'http://guacamole.itmat.upenn.edu/tpp/cgi-bin/pepxml2html.pl?xmlfile=' #BASE URL FOR TPP TRANSFORMATIONS
PROTXML2HTML_PREFIX = 'http://guacamole.itmat.upenn.edu/tpp/cgi-bin/protxml2html.pl?xmlfile=' #ANOTHER BASE URL FOR TPP TRANSFORMATIONS
QSUB_JOB_SUFFIX = '.kimchee-c' # SUFFIX TO GET INFO FOR A JOB VIA QSTAT. MUST MATCH TORQUE SERVER I THINK
SEQUEST_RESULTS = '/cygdrive/i/sequest/results' #PATH TO RESULTS FILES ON SEQUEST SERVER
SEQUEST_PARAMS = '/cygdrive/s/sequest/params' #PATH TO PARAMS FILES ON SEQUEST - DEPECATED
MASCOT_PARAMS = '/cygdrive/s/mascot/params' #PATH TO MASCOT PARAMS FILES ON SEQUEST - DEPRECATED
QSUB_BATCH = '-q batch' # DEFAULT QUEUE FOR SEQUEST SUBMISSIONS
QSUB_CONCUR = '-q concur' # DEFAULT QUEUE FOR CONCURRENT SUBMISSIONS (NOT SEQUEST SEARCHES)
PBS_SERVER = '' # PBS SUBMIT SERVER GETS APPENDED TO QUEUE TYPE
MASCOT_DATA ='/opt/mascot/data' # I DUNNO DEPRECATED MAYBE
SEQUEST_DATABASE = '/cygdrive/s/sequest/database' # DATABASE LIST ON SEQUEST
SEQUEST_EXTRACT_PARAMS = '/cygdrive/s/sequest/extract_params' # EXTRACT PARAMS PATH ON SEQUEST - DEPRECATED
BIN_PATH = '/opt/tpp/`uname -p`/bin' # PATH RELATIVE TO BLADES FOR TPP INSTALLATION
DB_ROOT = '/data/www/htdocs/qInteract/dblib' # PATH RELATIVE TO BLADES OF PROT DATABASE
TEMP_SHARE = '/home/qinteract/tmp'  # shared temp directory FOR TEMP WRITING OF PARAMS FILES FROM DATABASE TO UPLOAD FOR JOB EXECUTION.
DATAFILE_PATH_PREFIX = '/mnt/san/lims1/data_files' # path prefix for data files from the lims
AUDIT_URL = 'http://bioinf.itmat.upenn.edu/qInteract2/job/audit' # for audit reporting
TRACEJOB_CMD = 'ssh pbs tracejob ' #tracejob command may be ssh
ARCHIVE_ROOT = '/data/archive'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_qinteract3_session',
    :secret      => '436ea7d9133714e4379fd7cecd925c64291f62269ac52a8e360a7618e91232d0dba1ffb07776535d6fd7734e1e55e12317049b708123fb5d654098b3a2ff7d34'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
end

# Include your application configuration below
Inflector.inflections do |inflect|
   inflect.irregular 'analysis', 'analyses'
 end

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(
  :datestamp => "%Y%m%d" 
)


CASClient::Frameworks::Rails::Filter.configure(
    :cas_base_url => "https://ctrc.itmat.upenn.edu/auth"
)
