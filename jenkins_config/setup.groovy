#!groovy

import jenkins.model.*
import hudson.security.*
import hudson.util.*;
import jenkins.install.*;

def instance = Jenkins.getInstance()
def username = "administrator"
def password = "topsecretpassword"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(username, password)
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.add(Jenkins.ADMINISTER, username)
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
