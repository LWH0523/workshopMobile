import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseTest {
  static final supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> getTaskDeliverDetails() async {
    try {
      print("🔍 DEBUG: Starting getTaskDeliverDetails query...");
      final response = await supabase
          .from('taskDeliver')
          .select('''
            id, 
            component_id,
            quantity,
            destination, 
            dueDate, 
            status, 
            time, 
            user_id, 
            contact_number,
            signature,
            image,
            paymentType,
            paymentStatus,
            messageOfDeliver,
            task_deliver_component(
              component(
                id,
                name,
                qty,
                workshop,
                destination,
                business_hour
              )
            )
          ''')
          .limit(10); // adjust limit as needed

      print("🔍 DEBUG: Raw response from database: $response");
      final result = List<Map<String, dynamic>>.from(response);
      print("🔍 DEBUG: Processed ${result.length} tasks");
      for (int i = 0; i < result.length; i++) {
        print("🔍 DEBUG: Task $i: ${result[i]}");
      }
      return result;
    } catch (e) {
      print("❌ Error retrieving taskDeliver details: $e");
      return [];
    }
  }
  static Future<List<Map<String, dynamic>>> getComponentDetails() async {
    try {
      final response = await supabase
          .from('component')
          .select('id, name, quantity, category_id, date, time,workshop, destination')
          .limit(10); // adjust limit as needed

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error retrieving taskDeliver details: $e");
      return [];
    }
  }

  // Fetch components for a specific task id using the task_deliver_component junction table
  static Future<List<Map<String, dynamic>>> getComponentsByTaskId(dynamic taskId) async {
    try {
      print("🔍 DEBUG: Fetching components for taskId: $taskId");
      final response = await supabase
          .from('task_deliver_component')
          .select('''
            component(
              id,
              name,
              qty,
              category_id,
              date,
              time,
              destination,
              workshop,
              business_hour
            )
          ''')
          .eq('taskDeliver_id', taskId)
          .order('id');

      print("🔍 DEBUG: Raw component response: $response");

      // Transform the response to match the expected format
      final List<Map<String, dynamic>> transformedData = [];
      for (final item in response) {
        print("🔍 DEBUG: Processing component item: $item");
        final component = item['component'];
        if (component != null) {
          print("🔍 DEBUG: Component data: $component");
          transformedData.add({
            'id': component['id'],
            'name': component['name'],
            'qty': component['qty'], // Use quantity from component table
            'category_id': component['category_id'],
            'date': component['date'],
            'time': component['time'],
            'destination': component['destination'],
            'workshop': component['workshop'],
            'business_hour': component['business_hour'],
            'task_id': taskId,
          });
        }
      }

      print("🔍 DEBUG: Transformed ${transformedData.length} components for task $taskId");
      return transformedData;
    } catch (e) {
      print("❌ Error retrieving components for task $taskId: $e");
      return [];
    }
  }

  // Fetch components by workshop name
  static Future<List<Map<String, dynamic>>> getComponentsByWorkshop(String workshop) async {
    try {
      final response = await supabase
          .from('component')
          .select('id, name, qty, category_id, date, time, destination, workshop')
          .eq('workshop', workshop)
          .order('id');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("❌ Error retrieving components for workshop $workshop: $e");
      return [];
    }
  }

  // Get a single task with its components using the new table structure
  static Future<Map<String, dynamic>?> getTaskWithComponents(int taskId) async {
    try {
      final response = await supabase
          .from('taskDeliver')
          .select('''
            id, 
            destination, 
            dueDate, 
            status, 
            time, 
            user_id, 
            contact_number,
            signature,
            image,
            paymentType,
            paymentStatus,
            messageOfDeliver,
            task_deliver_component(
              quantity,
              component(
                id,
                name,
                qty,
                category_id,
                date,
                time,
                destination,
                workshop,
                business_hour
              )
            )
          ''')
          .eq('id', taskId)
          .single();

      return response;
    } catch (e) {
      print("❌ Error retrieving task $taskId with components: $e");
      return null;
    }
  }
  /// Test database connection and table existence
  static Future<Map<String, dynamic>> testDatabaseConnection() async {
    Map<String, dynamic> results = {
      'connection': false,
      'taskDeliverTable': false,
      'componentTable': false,
      'taskDeliveryComponentTable': false,
      'taskDeliverData': null,
      'componentData': null,
      'taskDeliveryComponentData': null,
      'errors': <String>[],
    };

    try {
      // Test basic connection
      print("🔍 Testing Supabase connection...");
      await supabase.from('taskDeliver').select('count').limit(1);
      results['connection'] = true;
      print("✅ Database connection successful");

      // Test taskDeliver table
      try {
        print("🔍 Testing taskDeliver table...");
        final taskData = await supabase
            .from('taskDeliver')
            .select()
            .limit(5);
        results['taskDeliverTable'] = true;
        results['taskDeliverData'] = taskData;
        print("✅ taskDeliver table accessible, found ${taskData.length} records");
      } catch (e) {
        results['errors'].add('taskDeliver table error: $e');
        print("❌ taskDeliver table error: $e");
      }

      // Test component table
      try {
        print("🔍 Testing component table...");
        final componentData = await supabase
            .from('component')
            .select()
            .limit(5);
        results['componentTable'] = true;
        results['componentData'] = componentData;
        print("✅ component table accessible, found ${componentData.length} records");
      } catch (e) {
        results['errors'].add('component table error: $e');
        print("❌ component table error: $e");
      }

      // Test task_deliver_component table
      try {
        print("🔍 Testing task_deliver_component table...");
        final taskDeliveryComponentData = await supabase
            .from('task_deliver_component')
            .select()
            .limit(5);
        results['taskDeliveryComponentTable'] = true;
        results['taskDeliveryComponentData'] = taskDeliveryComponentData;
        print("✅ task_deliver_component table accessible, found ${taskDeliveryComponentData.length} records");
      } catch (e) {
        results['errors'].add('task_deliver_component table error: $e');
        print("❌ task_deliver_component table error: $e");
      }

      // Test specific query (id=1)
      try {
        print("🔍 Testing specific query for id=1...");
        final specificTask = await supabase
            .from('taskDeliver')
            .select()
            .eq('id', 1)
            .single();
        print("✅ Found task with id=1: ${specificTask.toString()}");
      } catch (e) {
        results['errors'].add('Specific query error: $e');
        print("❌ No task found with id=1: $e");
      }

    } catch (e) {
      results['errors'].add('Connection error: $e');
      print("❌ Database connection failed: $e");
    }

    return results;
  }

  /// Test the new task_deliver_component relationship
  static Future<Map<String, dynamic>> testTaskDeliveryComponentRelationship() async {
    Map<String, dynamic> results = {
      'success': false,
      'taskCount': 0,
      'componentCount': 0,
      'relationshipCount': 0,
      'sampleData': null,
      'errors': <String>[],
    };

    try {
      print("🔍 Testing task_deliver_component relationship...");

      // Get a sample task with its components
      final taskResponse = await supabase
          .from('taskDeliver')
          .select('''
            id,
            destination,
            task_deliver_component(
              component(
                id,
                name,
                workshop
              )
            )
          ''')
          .limit(1);

      if (taskResponse.isNotEmpty) {
        final task = taskResponse.first;
        final taskDeliveryComponents = task['task_deliver_component'] as List? ?? [];

        results['taskCount'] = 1;
        results['relationshipCount'] = taskDeliveryComponents.length;
        results['componentCount'] = taskDeliveryComponents.length;
        results['sampleData'] = {
          'taskId': task['id'],
          'destination': task['destination'],
          'components': taskDeliveryComponents.map((tdc) => {
            'componentName': tdc['component']?['name'],
            'quantity': tdc['component']?['qty'],
            'workshop': tdc['component']?['workshop'],
          }).toList(),
        };
        results['success'] = true;

        print("✅ Found task ${task['id']} with ${taskDeliveryComponents.length} components");
        for (final tdc in taskDeliveryComponents) {
          final component = tdc['component'];
          print("   - ${component?['name']}: ${component?['qty']} (${component?['workshop']})");
        }
      } else {
        results['errors'].add('No tasks found with components');
        print("❌ No tasks found with components");
      }

    } catch (e) {
      results['errors'].add('Relationship test error: $e');
      print("❌ Error testing relationship: $e");
    }

    return results;
  }

  /// Print database schema information
  static void printDatabaseInfo(Map<String, dynamic> results) {
    print("\n" + "="*50);
    print("📊 DATABASE TEST RESULTS");
    print("="*50);

    print("🔗 Connection: ${results['connection'] ? '✅ SUCCESS' : '❌ FAILED'}");
    print("📦 taskDeliver Table: ${results['taskDeliverTable'] ? '✅ ACCESSIBLE' : '❌ NOT ACCESSIBLE'}");
    print("🔧 component Table: ${results['componentTable'] ? '✅ ACCESSIBLE' : '❌ NOT ACCESSIBLE'}");
    print("🔗 task_deliver_component Table: ${results['taskDeliveryComponentTable'] ? '✅ ACCESSIBLE' : '❌ NOT ACCESSIBLE'}");

    if (results['taskDeliverData'] != null) {
      print("\n📋 taskDeliver Sample Data:");
      for (var item in results['taskDeliverData']) {
        print("   - ID: ${item['id']}, Fields: ${item.keys.toList()}");
      }
    }

    if (results['componentData'] != null) {
      print("\n🔧 component Sample Data:");
      for (var item in results['componentData']) {
        print("   - ID: ${item['id']}, Fields: ${item.keys.toList()}");
      }
    }

    if (results['taskDeliveryComponentData'] != null) {
      print("\n🔗 task_deliver_component Sample Data:");
      for (var item in results['taskDeliveryComponentData']) {
        print("   - ID: ${item['id']}, Fields: ${item.keys.toList()}");
      }
    }

    if (results['errors'].isNotEmpty) {
      print("\n❌ ERRORS:");
      for (var error in results['errors']) {
        print("   - $error");
      }
    }

    print("="*50);
  }
}

