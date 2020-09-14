#Defines the directory runtime will look for packages and resources
#For convinience
class_flag=-cp "target:src/main/resources:src/test/resources:target/sqlite-jdbc-3.32.3.2.jar"
compile=javac $(class_flag) -d target
run=java $(class_flag)

#*** Main Processes ***
#ContentServer
content: compile_content
ifeq ($(and $(url),$(file)),)
	@echo
	@echo "Usage: make content url=<url> file=<file_name>"
	@echo "<url>: <host_name>:<port_number>"
	@echo
else
	@$(run) main.java.content.ContentServer $(url) $(file)
endif

#GETClient
client: compile_client
ifeq ($(url),)
	@echo
	@echo "Usage: make client url=<url>"
	@echo "<url>: <host_name>:<port_number>"
	@echo
else
	$(run) main.java.client.GETClient $(url)
endif

#AggregationServer
server: compile_server
ifeq ($(port),)
	@echo
	@echo "Usage: make server port=<port_number>"
	@echo "if <port_number> is left empty, then port is set to 4567"
	@echo
endif
	@$(run) main.java.server.AggregationServer $(port)


#*** Tests ***
test_class_flag=-cp "target:src/test/resources:target/junit-4.13.jar:target/hamcrest-core-1.3.jar:target/sqlite-jdbc-3.32.3.2.jar"
compile_test=javac $(test_class_flag) -d target
run_test=java $(test_class_flag) org.junit.runner.JUnitCore

test_http: compile_test_http
	$(run_test) test.java.http.URLParserTest
	$(run_test) test.java.http.HTTPResponseWriterTest

compile_test_http: compile_http src/test/java/http/*.java
	@$(compile_test) src/test/java/http/*.java

test_server: compile_test_server
	$(run_test) test.java.server.AggregationStorageManagerTest

test_slow_server: compile_test_server
	$(run_test) test.java.server.AggregationStorageManagerSlowTest

compile_test_server: compile_server src/test/java/server/*.java
	@$(compile_test) src/test/java/server/*.java

test_atom: compile_test_atom
	$(run_test) test.java.atom.TextToAtomParserTest

compile_test_atom: compile_atom src/test/java/atom/*.java
	$(compile_test) src/test/java/atom/*.java 


#***Compliation***
compile_client: src/main/java/client/*java compile_http
	@$(compile) src/main/java/client/*java

compile_content: src/main/java/content/*java compile_http
	@$(compile) src/main/java/content/*java

compile_server: src/main/java/server/*.java compile_http
	@$(compile) src/main/java/server/*java

#HTTP helpers
compile_http: src/main/java/http/*.java
	@$(compile) $?

#Atom helpers
compile_atom: src/main/java/atom/*.java
	$(compile) $?
