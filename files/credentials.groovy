import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
println("Setting credentials")
def domain = Domain.global()
def store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()

def credentials= ['username':'gauravagnihotri25', 'password':'taTT00--!psec', 'id':'Dockerhub', 'description':'Docker_hub_Credentials'] as java.lang.Object
def user = new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL, 'artifactoryCredentials', credentials.description, credentials.username, credentials.password, credentials.id) as java.lang.Object
store.addCredentials(domain, user)

