# == Class: role::poolcounter
#
# Installs pool counter service and configures wikis to use it for article
# views.
#
class role::poolcounter {
    require_package('poolcounter')

    service { 'poolcounter':
        enable  => true,
        ensure  => 'running',
        require => Package['poolcounter'],
    }

    mediawiki::extension { 'PoolCounter':
        priority => $::LOAD_EARLY,
        settings => [
            '$wgPoolCountClientConf["servers"][] = "127.0.0.1";',
            '$wgPoolCountClientConf["timeout"] = 0.5;',
            '$wgPoolCounterConf["ArticleView"]["class"] = "PoolCounter_Client";',
            '$wgPoolCounterConf["ArticleView"]["timeout"] = 15;',
            '$wgPoolCounterConf["ArticleView"]["workers"] = 2;',
            '$wgPoolCounterConf["ArticleView"]["maxqueue"] = 100;',
        ],
        require  => Service['poolcounter'],
    }
}
