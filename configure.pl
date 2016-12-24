#!/usr/bin/perl

use Cwd 'abs_path';
use File::Basename;
use File::Copy;

#
# Script to Install my configuration files across linux wordkstations
#
# Actions:
#   -For each user
#       - Configure bash
#       - Configure zsh
#       - ..
#   - Copy public ssh keys
#   - Install several scripts
#   - Append hotss to /etc/hosts
#   - ..
#
# Directories
#    local-scripts:      This scripts will be copied to /usr/local/bin
#    home-conf-files:    This files will be copied to the user home
#    conf-files:         Several conf files
#


use strict;
use warnings;

my $SCRIPT_DIR          = dirname( abs_path($0) );
my $HOMECONF_FILES_DIR  = "$SCRIPT_DIR/home-conf-files/";
my $CONF_FILES_DIR      = "$SCRIPT_DIR/conf-files/";
my $MAC_CONF_FILES_DIR  = "$SCRIPT_DIR/mac-conf-files/";
my $SCRIPTS_DIR         = "$SCRIPT_DIR/local-scripts/";

sub get_valid_users_from_input
{
    print "Type the usernames separated by commas to apply configuration files (Default value:root)\n";
    my $uinput =<STDIN>;
    chomp($uinput);

    my @users = ("root");

    @users = split(",",$uinput) if ($uinput ne "");

    $_ =~ s/^\s+// foreach (@users);

    foreach (@users) {
        die("$_ is not a valid user") if (!is_valid_user($_));
    }

    return @users;
}

sub is_valid_user
{
    my ($username) = @_;
    `id $username  > /dev/null 2>&1 `;
    return 1 if ($? == 0);
    return 0;
}

sub get_home_user_dir
{
    my ($username) = @_;
    if (is_macos() ){
        return "/var/root/" if ($username eq "root");
        return "/Users/$username/";
    }else{
        return "/root/" if ($username eq "root");
        return "/home/$username/";
    }
}

sub change_user_file_permission
{
    my ($username,$file) = @_;
    return chmod 0755 ,$file;
}

sub copy_file_and_change_perm
{
    my ($user,$orig_file,$dest_file) = @_;
    print "Copying from $orig_file to $dest_file\n";
    copy($orig_file,$dest_file) or die("Copy Failed:$orig_file to $dest_file $!");
    if ($user ne "root"){
        change_user_file_permission($user,get_home_user_dir($user)."/.bashrc") || die ("Couldn change file permission");
    }
}

sub is_macos 
{
    return 1 if (-d "/Users/");
}

sub get_file_contents
{
    my ($file)  = @_;
    open FILE,"<$file" or die "Could not open file '$file' $!";
    my @lines = <FILE>;
    close FILE;
    return @lines;
}

sub append_file_to_file
{
    my ($from,$to)  = @_;
    
    open(my $fh, '>>', $to) or die "Could not open file '$to' $!";
    foreach (get_file_contents($from)) {
        print $fh $_;
    }
    close $fh;
}

sub get_dir_files
{
    my ($conf_dir) = @_;
    opendir my $dir, $conf_dir or die "Cannot open directory: $!";
    my @files = readdir $dir;
    closedir $dir;
    @files= grep (! /^\.$|^\.\.$/, @files);
    $_ = "$conf_dir/$_" foreach (@files);
    return @files;
}

sub copy_all_home_conf_files
{
    my ($user,$conf_dir) = @_;
    opendir my $dir, $conf_dir or die "Cannot open directory: $!";
    my @files = readdir $dir;
    closedir $dir;

    foreach (get_dir_files($conf_dir) ){
        if ($_ =~ /bashrc$/ and is_macos() ){
            copy_file_and_change_perm($user,$_,get_home_user_dir($user)."/.bash_profile");
        }else{
            copy_file_and_change_perm($user,$_,get_home_user_dir($user));
        }
    }
}

sub install_all_scripts
{
    my ($scripts_dir ) = @_;
    print "\nInstalling my scripts\n";
    copy_file_and_change_perm("root",$_,"/usr/local/bin/") foreach ( get_dir_files($scripts_dir) );
}

sub show_keys
{
    my (@keys) = @_;
    for(my $cnt=0;$cnt<scalar(@keys);$cnt++){
        print "\t$cnt: ".basename($keys[$cnt])."\n";
    }
}

sub prompt_install_ssh_keys
{
    my ($user,$keys_dir) = @_;
    my @keys = get_dir_files($keys_dir);
    print "\n\nWich ssh keys do you want to install for $user? (ENTER KEY to end)\n";
    show_keys(@keys);
    while (<STDIN>) {
        chomp($_);
        last if ($_ eq "");
        if ($_ =~ /^\d+$/ && defined $keys[$_] ){
            print "Adding " . basename($keys[$_]) . " to ".get_home_user_dir($user)."/.ssh/authorized_keys\n";
            append_file_to_file($keys[$_],get_home_user_dir($user)."/.ssh/authorized_keys"  );
        }else{
            print "No key found!\n";
        }
    }
}

sub prompt_add_raw_hosts
{
    my ($CONF_FILES_DIR) = @_;
    print "\n\nAppend hosts to etc/hosts? (ENTER to ignore)\n";
    print "1: internal lan host\n";
    print "2: external host\n";
    while (<STDIN>) {
        chomp($_);
        last if ($_ eq "");
        if ($_ eq "1"){
            print "Appending internal lan host file..\n";
            append_file_to_file("$CONF_FILES_DIR/raw-hosts.lan","/etc/hosts");
        }elsif($_ eq "2"){
            print "Appending external host file..\n";
            append_file_to_file("$CONF_FILES_DIR/raw-hosts","/etc/hosts");
        }else{
            print "You have to select some valid value\n";
        }
    }
   
}

#######################################################################################################################
#                                       MAIN                                                                          #
#######################################################################################################################

die("Root privileges needed for this script") if (`whoami` !~ /root/);

foreach my $user (get_valid_users_from_input()){
    print "\nConfiguring $user\n";
    copy_all_home_conf_files($user,$HOMECONF_FILES_DIR);
    append_file_to_file("$MAC_CONF_FILES_DIR/vim-home-end.txt",get_home_user_dir($user)."/.vimrc") if (is_macos() );
    prompt_install_ssh_keys($user,"$CONF_FILES_DIR/sshkeys");
}

install_all_scripts($SCRIPTS_DIR);

prompt_add_raw_hosts($CONF_FILES_DIR);

