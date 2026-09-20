// dart format off
// ignore_for_file: type=lint

// GENERATED FILE, DO NOT MODIFY
// Generated with jaspr_builder

import 'dart:io';
import 'dart:convert';

import 'package:jaspr/src/dom/styles/rules.dart'
    show StyleRule, StyleRulesRender;
import 'package:ecomes/constants/theme.dart' as _theme;

void main() {
  final List<StyleRule> styles = [..._theme.styles];

  stdout.write(jsonEncode({'css': styles.render()}));
}
