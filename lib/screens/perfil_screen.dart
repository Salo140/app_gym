import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:image_picker/image_picker.dart';

import '../data/mock_data.dart';
import '../data/repositories/local_notification_service.dart';
import '../data/repositories/profile_image_repository.dart';
import '../data/repositories/workout_repository.dart';
import '../models/saved_workout.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';

/// Equivale a `PerfilView.tsx`.
class PerfilView extends StatefulWidget {
  const PerfilView({
    super.key,
    required this.streakDays,
    required this.email,
    required this.ownerId,
    required this.workoutRepository,
    required this.profileImageRepository,
    required this.notificationService,
    required this.onSignOut,
  });

  final int streakDays;
  final String email;
  final String ownerId;
  final WorkoutRepository workoutRepository;
  final ProfileImageRepository profileImageRepository;
  final LocalNotificationService notificationService;
  final VoidCallback onSignOut;

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  int _defaultRestTime = 90;
  bool _soundAlerts = true;
  bool _vibrationAlerts = true;
  String _weightUnit = 'kg';
  String _displayName = '';
  String _trainingLevel = 'Intermedio';
  String _goal = 'Hipertrofia';
  String? _profileImagePath;
  String? _profileImageUrl;
  late Future<List<SavedWorkoutPlan>> _savedPlans;
  bool _sendingTestNotification = false;
  bool _savingProfileImage = false;

  @override
  void initState() {
    super.initState();
    _savedPlans = widget.workoutRepository.getPlans(widget.ownerId);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final values = await Future.wait([
        widget.workoutRepository.getPreference(widget.ownerId, 'rest_seconds'),
        widget.workoutRepository.getPreference(widget.ownerId, 'sound_alerts'),
        widget.workoutRepository.getPreference(
          widget.ownerId,
          'vibration_alerts',
        ),
        widget.workoutRepository.getPreference(widget.ownerId, 'weight_unit'),
        widget.workoutRepository.getPreference(widget.ownerId, 'profile_name'),
        widget.workoutRepository.getPreference(
          widget.ownerId,
          'training_level',
        ),
        widget.workoutRepository.getPreference(widget.ownerId, 'fitness_goal'),
        widget.workoutRepository.getPreference(
          widget.ownerId,
          'profile_image_path',
        ),
        widget.workoutRepository.getPreference(
          widget.ownerId,
          'profile_image_url',
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _defaultRestTime = int.tryParse(values[0] ?? '') ?? _defaultRestTime;
        if (values[1] != null) _soundAlerts = values[1] == 'true';
        if (values[2] != null) _vibrationAlerts = values[2] == 'true';
        _weightUnit = values[3] ?? _weightUnit;
        _displayName = values[4] ?? _displayName;
        _trainingLevel = values[5] ?? _trainingLevel;
        _goal = values[6] ?? _goal;
        _profileImagePath = values[7];
        _profileImageUrl = values[8];
      });
      if (_profileImagePath == null) await _loadCloudProfileImage();
    } on DatabaseException {
      if (mounted) {
        showGymToast(
          context,
          'No se pudieron cargar las preferencias guardadas.',
        );
      }
    }
  }

  Future<void> _loadCloudProfileImage() async {
    try {
      final url = await widget.profileImageRepository.getProfileImageUrl(
        widget.ownerId,
      );
      if (url == null || !mounted) return;
      setState(() => _profileImageUrl = url);
      await widget.workoutRepository.setPreference(
        widget.ownerId,
        'profile_image_url',
        url,
      );
    } on FirebaseException catch (error) {
      if (mounted) {
        showGymToast(
          context,
          'No se pudo cargar la foto de la nube: ${error.message ?? error.code}',
        );
      }
    } on DatabaseException {
      if (mounted) {
        showGymToast(context, 'No se pudo guardar la referencia de la foto.');
      }
    }
  }

  Future<void> _selectProfileImage() async {
    if (_savingProfileImage) return;
    setState(() => _savingProfileImage = true);
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image == null) return;

      final supportDirectory = await getApplicationSupportDirectory();
      final imageDirectory = Directory(
        path.join(supportDirectory.path, 'profile-images'),
      );
      await imageDirectory.create(recursive: true);
      final ownerKey = base64Url
          .encode(utf8.encode(widget.ownerId))
          .replaceAll('=', '');
      final localPath = path.join(imageDirectory.path, '$ownerKey.jpg');
      await image.saveTo(localPath);
      if (!mounted) return;
      setState(() {
        _profileImagePath = localPath;
        _profileImageUrl = null;
      });

      await widget.workoutRepository.setPreference(
        widget.ownerId,
        'profile_image_path',
        localPath,
      );
      await widget.workoutRepository.setPreference(
        widget.ownerId,
        'profile_image_url',
        '',
      );
      if (!mounted) return;
      if (!widget.profileImageRepository.cloudConfigured) {
        showGymToast(
          context,
          'Foto guardada en el dispositivo. Configura Storage para subirla a la nube.',
        );
        return;
      }

      final url = await widget.profileImageRepository.uploadProfileImage(
        ownerId: widget.ownerId,
        localPath: localPath,
      );
      if (url == null) return;
      await widget.workoutRepository.setPreference(
        widget.ownerId,
        'profile_image_url',
        url,
      );
      if (!mounted) return;
      setState(() => _profileImageUrl = url);
      showGymToast(context, 'Foto guardada y sincronizada con Firebase.');
    } on PlatformException catch (error) {
      if (mounted) {
        showGymToast(
          context,
          'No se pudo seleccionar la imagen: ${error.message ?? error.code}',
        );
      }
    } on FileSystemException catch (error) {
      if (mounted) {
        showGymToast(context, 'No se pudo guardar la imagen: ${error.message}');
      }
    } on DatabaseException {
      if (mounted) {
        showGymToast(context, 'No se pudo guardar la foto en el perfil local.');
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        showGymToast(
          context,
          'La foto quedó guardada localmente, pero no se pudo subir: '
          '${error.message ?? error.code}',
        );
      }
    } finally {
      if (mounted) setState(() => _savingProfileImage = false);
    }
  }

  Future<void> _sendTestNotification() async {
    setState(() => _sendingTestNotification = true);
    try {
      await widget.notificationService.showTestNotification();
      if (mounted) showGymToast(context, 'Notificación de prueba enviada.');
    } on StateError catch (error) {
      if (mounted) showGymToast(context, error.message);
    } on UnsupportedError catch (error) {
      if (mounted) showGymToast(context, error.message ?? error.toString());
    } on PlatformException catch (error) {
      if (mounted) {
        showGymToast(
          context,
          'No se pudo enviar la notificación: ${error.message ?? error.code}',
        );
      }
    } finally {
      if (mounted) setState(() => _sendingTestNotification = false);
    }
  }

  Future<void> _savePreference(String key, String value) async {
    try {
      await widget.workoutRepository.setPreference(widget.ownerId, key, value);
    } on DatabaseException {
      if (mounted) {
        showGymToast(
          context,
          'No se pudo guardar la preferencia en este dispositivo.',
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    try {
      await Future.wait([
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'rest_seconds',
          '$_defaultRestTime',
        ),
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'sound_alerts',
          '$_soundAlerts',
        ),
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'vibration_alerts',
          '$_vibrationAlerts',
        ),
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'weight_unit',
          _weightUnit,
        ),
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'profile_name',
          _displayName,
        ),
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'training_level',
          _trainingLevel,
        ),
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'fitness_goal',
          _goal,
        ),
      ]);
      if (mounted) {
        showGymToast(context, 'Preferencias guardadas en el dispositivo.');
      }
    } on DatabaseException {
      if (mounted) {
        showGymToast(context, 'No se pudieron guardar las preferencias.');
      }
    }
  }

  Future<void> _editProfile() async {
    final controller = TextEditingController(
      text: _displayName.isEmpty ? widget.email.split('@').first : _displayName,
    );
    final formKey = GlobalKey<FormState>();
    var level = _trainingLevel;
    var goal = _goal;
    final result = await showDialog<(String, String, String)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar perfil'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  maxLength: 40,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => (value?.trim().length ?? 0) < 2
                      ? 'Escribe al menos 2 caracteres'
                      : null,
                ),
                DropdownButtonFormField<String>(
                  initialValue: level,
                  decoration: const InputDecoration(labelText: 'Nivel'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Principiante',
                      child: Text('Principiante'),
                    ),
                    DropdownMenuItem(
                      value: 'Intermedio',
                      child: Text('Intermedio'),
                    ),
                    DropdownMenuItem(
                      value: 'Avanzado',
                      child: Text('Avanzado'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => level = value);
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: goal,
                  decoration: const InputDecoration(labelText: 'Objetivo'),
                  items: const [
                    DropdownMenuItem(value: 'Fuerza', child: Text('Fuerza')),
                    DropdownMenuItem(
                      value: 'Hipertrofia',
                      child: Text('Hipertrofia'),
                    ),
                    DropdownMenuItem(
                      value: 'Resistencia',
                      child: Text('Resistencia'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => goal = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(dialogContext, (
                  controller.text.trim(),
                  level,
                  goal,
                ));
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result == null) return;
    try {
      await Future.wait([
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'profile_name',
          result.$1,
        ),
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'training_level',
          result.$2,
        ),
        widget.workoutRepository.setPreference(
          widget.ownerId,
          'fitness_goal',
          result.$3,
        ),
      ]);
      if (!mounted) return;
      setState(() {
        _displayName = result.$1;
        _trainingLevel = result.$2;
        _goal = result.$3;
      });
    } on DatabaseException {
      if (mounted) {
        showGymToast(context, 'No se pudo guardar el perfil localmente.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ContentShell(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            20,
            topInset(context) + 8,
            20,
            bottomInset(context),
          ),
          children: [
            _profileCard(),
            const SizedBox(height: 16),
            _routineCard(),
            const SizedBox(height: 16),
            _preferencesCard(),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Cerrar sesión',
              icon: Symbols.logout,
              onPressed: widget.onSignOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard() {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.fade(AppColors.primary, 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _profileAvatarImage(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Semantics(
                  button: true,
                  label: 'Cambiar foto de perfil',
                  child: GestureDetector(
                    onTap: _savingProfileImage ? null : _selectProfileImage,
                    child: Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Symbols.photo_camera,
                        size: 13,
                        color: AppColors.onPrimary,
                        weight: 700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _displayName.isNotEmpty
                ? _displayName
                : widget.email.isEmpty
                ? 'Atleta GymMate'
                : widget.email,
            textAlign: TextAlign.center,
            style: AppText.headlineMd(size: 20),
          ),
          const SizedBox(height: 2),
          Text('Atleta $_trainingLevel • $_goal', style: AppText.bodySm()),
          TextButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Symbols.edit, size: 16),
            label: const Text('Editar perfil'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pill(
                label: '🔥 Racha activa: ${widget.streakDays} días',
                background: AppColors.fade(AppColors.primary, 0.15),
                foreground: AppColors.primaryLight,
                borderColor: AppColors.fade(AppColors.primary, 0.3),
                fontSize: 12,
                bold: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
              ),
              const SizedBox(width: 8),
              Pill(
                label: 'Plan gratuito',
                background: AppColors.fade(AppColors.secondaryLight, 0.15),
                foreground: AppColors.secondaryLight,
                borderColor: AppColors.fade(AppColors.secondaryLight, 0.3),
                fontSize: 12,
                bold: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.cardBorderSoft),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _bioTile('Peso', '—')),
              const SizedBox(width: 8),
              Expanded(child: _bioTile('Altura', '—')),
              const SizedBox(width: 8),
              Expanded(
                child: _bioTile('Grasa Est.', '—', color: AppColors.tertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileAvatarImage() {
    final localPath = _profileImagePath;
    if (localPath != null && localPath.isNotEmpty) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _profileNetworkImage(),
      );
    }
    return _profileNetworkImage();
  }

  Widget _profileNetworkImage() {
    final url = _profileImageUrl;
    if (url == null || url.isEmpty) {
      return const RemoteImage(url: Assets.userAvatar);
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const RemoteImage(url: Assets.userAvatar),
    );
  }

  Widget _bioTile(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.fade(AppColors.surfaceHigh, 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: AppText.labelSm(size: 10, letterSpacing: 0)),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppText.metric(
              color: color ?? AppColors.onSurface,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _routineCard() {
    return FutureBuilder<List<SavedWorkoutPlan>>(
      future: _savedPlans,
      builder: (context, snapshot) {
        final plans = snapshot.data ?? const <SavedWorkoutPlan>[];
        return SurfaceCard(
          borderColor: AppColors.cardBorderSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Symbols.fitness_center,
                    size: 20,
                    color: AppColors.primaryLight,
                  ),
                  const SizedBox(width: 8),
                  Text('Mis planes guardados', style: AppText.headlineSm(size: 14)),
                  const Spacer(),
                  Text(
                    '${plans.length}',
                    style: AppText.labelSm(
                      color: AppColors.primary,
                      size: 11,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState != ConnectionState.done)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (snapshot.hasError)
                Text(
                  'No se pudieron cargar tus planes guardados.',
                  style: AppText.bodySm(color: AppColors.error, size: 12),
                )
              else if (plans.isEmpty)
                Text(
                  'Aún no tienes planes. Crea uno desde la sección Entrenar.',
                  style: AppText.bodySm(size: 12),
                )
              else
                ...plans.map(
                  (savedPlan) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.fade(AppColors.surfaceHigh, 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorderSoft),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Symbols.assignment,
                          size: 18,
                          color: AppColors.primaryLight,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                savedPlan.plan.name,
                                style: AppText.bodyMd(
                                  color: AppColors.onSurface,
                                  size: 12,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${savedPlan.plan.goal} · '
                                '${savedPlan.plan.days} días/semana',
                                style: AppText.bodySm(size: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _preferencesCard() {
    return SurfaceCard(
      borderColor: AppColors.cardBorderSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Symbols.tune,
                size: 20,
                color: AppColors.secondaryLight,
              ),
              const SizedBox(width: 8),
              Text(
                'Ajustes de Sesión y Descanso',
                style: AppText.headlineSm(size: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Descanso predeterminado
          _settingRow(
            title: 'Descanso predeterminado',
            subtitle: 'Segundos automáticos entre series',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _roundButton('-', () {
                  final next = _defaultRestTime > 30
                      ? _defaultRestTime - 15
                      : _defaultRestTime;
                  setState(() => _defaultRestTime = next);
                  _savePreference('rest_seconds', '$next');
                }),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${_defaultRestTime}s',
                    textAlign: TextAlign.center,
                    style: AppText.metric(
                      color: AppColors.secondaryLight,
                      size: 14,
                    ),
                  ),
                ),
                _roundButton('+', () {
                  final next = _defaultRestTime + 15;
                  setState(() => _defaultRestTime = next);
                  _savePreference('rest_seconds', '$next');
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Alerta sonora
          _settingRow(
            title: 'Alerta sonora de descanso',
            subtitle: 'Sonido sutil al finalizar la cuenta atrás',
            trailing: _switch(
              value: _soundAlerts,
              onChanged: (v) {
                setState(() => _soundAlerts = v);
                _savePreference('sound_alerts', '$v');
              },
            ),
          ),
          const SizedBox(height: 12),

          // Vibración
          _settingRow(
            title: 'Respuesta háptica / Vibración',
            subtitle: 'Pulsos al confirmar registro de series',
            trailing: _switch(
              value: _vibrationAlerts,
              onChanged: (v) {
                setState(() => _vibrationAlerts = v);
                _savePreference('vibration_alerts', '$v');
              },
            ),
          ),
          const SizedBox(height: 12),

          // Unidad
          _settingRow(
            title: 'Unidad de carga',
            subtitle: 'Kilogramos (kg) o Libras (lbs)',
            trailing: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [_unitButton('kg'), _unitButton('lbs')],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Guardar Preferencias',
            height: 46,
            radius: 12,
            onPressed: _savePreferences,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _sendingTestNotification
                  ? null
                  : _sendTestNotification,
              icon: _sendingTestNotification
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Symbols.notifications_active),
              label: const Text('Enviar notificación de prueba'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingRow({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fade(AppColors.surfaceHigh, 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorderSoft),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.bodyMd(
                    color: AppColors.onSurface,
                    size: 12,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.bodySm(size: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Widget _roundButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surfaceHighest,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: AppText.headlineSm(size: 16, color: AppColors.onSurface),
        ),
      ),
    );
  }

  Widget _switch({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 26,
        padding: const EdgeInsets.all(2),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.surfaceHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x40000000), blurRadius: 4)],
          ),
        ),
      ),
    );
  }

  Widget _unitButton(String unit) {
    final selected = _weightUnit == unit;
    return GestureDetector(
      onTap: () {
        setState(() => _weightUnit = unit);
        _savePreference('weight_unit', unit);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          unit,
          style: AppText.labelMd(
            color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            size: 12,
            weight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
