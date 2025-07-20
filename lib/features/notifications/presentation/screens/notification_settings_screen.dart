import 'package:flutter/material.dart';
import '../../../../core/constants/theme_constants.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Notification preferences
  bool _jobApplications = true;
  bool _jobUpdates = true;
  bool _payments = true;
  bool _verification = true;
  bool _chat = true;
  bool _system = false;
  
  // General settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEndTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mipangilio ya Arifa'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notification Types Section
          _buildSectionHeader('Aina za Arifa'),
          _buildNotificationTypeTile(
            'Maombi ya Kazi',
            'Arifa unapopokea maombi mapya ya kazi',
            Icons.work,
            _jobApplications,
            (value) => setState(() => _jobApplications = value),
          ),
          _buildNotificationTypeTile(
            'Mabadiliko ya Kazi',
            'Arifa kuhusu kazi uliyoomba au kutoa',
            Icons.update,
            _jobUpdates,
            (value) => setState(() => _jobUpdates = value),
          ),
          _buildNotificationTypeTile(
            'Malipo',
            'Arifa kuhusu malipo na pesa',
            Icons.payment,
            _payments,
            (value) => setState(() => _payments = value),
          ),
          _buildNotificationTypeTile(
            'Uthibitishaji',
            'Arifa kuhusu uthibitishaji wa ID',
            Icons.verified_user,
            _verification,
            (value) => setState(() => _verification = value),
          ),
          _buildNotificationTypeTile(
            'Ujumbe',
            'Arifa kuhusu ujumbe mpya',
            Icons.chat,
            _chat,
            (value) => setState(() => _chat = value),
          ),
          _buildNotificationTypeTile(
            'Mfumo',
            'Arifa za mfumo na matangazo',
            Icons.info,
            _system,
            (value) => setState(() => _system = value),
          ),
          
          const SizedBox(height: 24),
          
          // General Settings Section
          _buildSectionHeader('Mipangilio ya Jumla'),
          _buildNotificationTypeTile(
            'Sauti',
            'Sikia sauti ya arifa',
            Icons.volume_up,
            _soundEnabled,
            (value) => setState(() => _soundEnabled = value),
          ),
          _buildNotificationTypeTile(
            'Vibration',
            'Pata vibration ya arifa',
            Icons.vibration,
            _vibrationEnabled,
            (value) => setState(() => _vibrationEnabled = value),
          ),
          
          const SizedBox(height: 16),
          
          // Quiet Hours Section
          _buildNotificationTypeTile(
            'Saa za Kimya',
            'Usipoke arifa kwa saa za usiku',
            Icons.bedtime,
            _quietHoursEnabled,
            (value) => setState(() => _quietHoursEnabled = value),
          ),
          
          if (_quietHoursEnabled) ...[
            const SizedBox(height: 16),
            _buildTimeRangeTile(),
          ],
          
          const SizedBox(height: 32),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: ThemeConstants.primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ThemeConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTypeTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: ThemeConstants.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: ThemeConstants.primaryColor,
          activeTrackColor: ThemeConstants.primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildTimeRangeTile() {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ThemeConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bedtime,
                    color: ThemeConstants.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Saa za Kimya',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerTile(
                    'Kuanza',
                    _quietStartTime,
                    (time) => setState(() => _quietStartTime = time),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePickerTile(
                    'Maliza',
                    _quietEndTime,
                    (time) => setState(() => _quietEndTime = time),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerTile(
    String label,
    TimeOfDay time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, 
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final newTime = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: ThemeConstants.primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (newTime != null) {
              onChanged(newTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: ThemeConstants.primaryColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
              color: ThemeConstants.primaryColor.withOpacity(0.05),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ThemeConstants.primaryColor,
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.access_time, 
                  size: 18,
                  color: ThemeConstants.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Hifadhi Mipangilio',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _resetToDefaults,
            style: OutlinedButton.styleFrom(
              foregroundColor: ThemeConstants.primaryColor,
              side: const BorderSide(color: ThemeConstants.primaryColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Rudisha Mipangilio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveSettings() {
    // TODO: Save settings to local storage or backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mipangilio imehifadhiwa'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _jobApplications = true;
      _jobUpdates = true;
      _payments = true;
      _verification = true;
      _chat = true;
      _system = false;
      _soundEnabled = true;
      _vibrationEnabled = true;
      _quietHoursEnabled = false;
      _quietStartTime = const TimeOfDay(hour: 22, minute: 0);
      _quietEndTime = const TimeOfDay(hour: 7, minute: 0);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mipangilio yamerudishwa'),
        backgroundColor: Colors.orange,
      ),
    );
  }
} 