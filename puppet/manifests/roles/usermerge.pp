# == Class: role::usermerge
# The UserMerge extension allows wiki users with the usermerge permission
# (Bureaucrat by default) to merge one Wiki user's account with another Wiki
# user's account.
class role::usermerge {
    include role::mediawiki
    mediawiki::extension { 'UserMerge': }
}

# == Define: ::role::usermerge::multiwiki
# Configure a multiwiki instance for UserMerge.
#
define role::usermerge::multiwiki {
    $wiki = $title
    multiwiki::extension { "${wiki}:UserMerge": }
}