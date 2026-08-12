import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trackify/theme/app_colors.dart';

enum Font {
  bold(FontWeight.w700),
  medium(FontWeight.w500),
  regular(FontWeight.w400),
  semibold(FontWeight.w600);

  final FontWeight value;
  const Font(this.value);
}

enum Decorate {
  underline(TextDecoration.underline),
  overline(TextDecoration.overline),
  lineThrough(TextDecoration.lineThrough),
  none(TextDecoration.none);

  final TextDecoration value;
  const Decorate(this.value);
}

class Txt extends StatelessWidget {
  final String text;
  final double? size;
  final Font weight;
  final Color? color;
  final Decorate decorate;
  final int? maxlines;
  final TextAlign? align;
  final TextOverflow? overflow;
  final double? spacing;
  final double? height;
  final bool showAsterisk;

  const Txt(
    this.text, {
    super.key,
    this.size = 14,
    this.weight = Font.regular,
    this.color,
    this.decorate = Decorate.none,
    this.maxlines,
    this.align,
    this.overflow,
    this.spacing = 0,
    this.height,
    this.showAsterisk = false,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: maxlines,
      textAlign: align ?? TextAlign.left,
      overflow: overflow ?? TextOverflow.clip,
      softWrap: true,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$text ',
            style: TextStyle(
              fontSize: size ?? 24.sp,
              fontWeight: weight.value,
              color: color ?? Theme.of(context).colorScheme.onSurface,
              decoration: decorate.value,
              letterSpacing: spacing,
              height: height,
              fontFamily: GoogleFonts.inter().fontFamily,
            ),
          ),
          if (showAsterisk)
            TextSpan(
              text: '*',
              style: TextStyle(
                fontSize: size ?? 24.sp,
                fontWeight: weight.value,
                color: AppColors.error,
                decoration: decorate.value,
                letterSpacing: spacing,
                height: height,
                fontFamily: GoogleFonts.inter().fontFamily,
              ),
            ),
        ],
      ),
    );
  }
}
