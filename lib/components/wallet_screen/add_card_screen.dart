'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emoney/components/add_card_screen/card_flipper.dart';
import 'package:emoney/components/add_card_screen/card_processing_screen.dart';
import 'package:emoney/utilities/card_identifier.dart';
import 'package:emoney/utilities/slide_right_route.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({
    Key? key,
  }) : super(key: key);

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen>
    with SingleTickerProviderStateMixin {
  late List<Widget> cardInputFields;
  late ItemScrollController _cardInputDataController;
  late TextEditingController _cardNumberInputController;
  late TextEditingController _expiryDateInputController;
  late TextEditingController _cvvInputController;
  late TextEditingController _cardHolderInputController;

  late CardFlippingController cardFlipper;

  late FocusScopeNode cardDetailsFocusNodes;
  late AnimationController cardSwitcher;
  late Animation<double> sides;

  Map<String, String> cardDetails = {
    'cardNumber': '',
    'expiryDate': '',
    'cvv': '',
    'cardHolder': ''
  };

  int _currentStep = 0;
  String cardBrand = "default";
  Image currentCardFrontSideImage = Image.asset(
    'assets/images/card_flow_assets/default-frontside.png',
    key: ValueKey(0),
  );
  late Image currentCardBackSideImage;

  @override
  void initState() {
    super.initState();
    _cardInputDataController = ItemScrollController();
    _cardNumberInputController = TextEditingController(text: "");
    _expiryDateInputController = TextEditingController(text: "");
    _cvvInputController = TextEditingController(text: "");
    _cardHolderInputController = TextEditingController(text: "");

    cardFlipper = CardFlippingController();

    cardDetailsFocusNodes = FocusScopeNode();
    cardInputFields = getCardInputFields();
    cardSwitcher =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));

    sides = Tween<double>(begin: 0.0, end: 1.0).animate(cardSwitcher);

    currentCardBackSideImage =
        Image.asset('assets/images/card_flow_assets/$cardBrand-backside.png');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(currentCardFrontSideImage.image, context);
    precacheImage(currentCardBackSideImage.image, context);
  }

  @override
  void dispose() {
    _cardNumberInputController.dispose();
    _expiryDateInputController.dispose();
    _cvvInputController.dispose();
    _cardHolderInputController.dispose();
    cardSwitcher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget cardFrontSide = Stack(
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 900),
          reverseDuration: Duration(seconds: 210),
          switchInCurve: Curves.linear,
          child: currentCardFrontSideImage,
          transitionBuilder: (Widget child, sides) {
            return AnimatedBuilder(
              animation: sides,
              child: child,
              builder: (BuildContext context, Widget? child) {
                return ClipPath(
                  clipper: CardClipperLeftToRight2(sideValue: sides.value),
                  child: child,
                );
              },
            );
          },
        ),
        Positioned.fill(
            child: Align(
          alignment: Alignment.center,
          child: Text(
            _cardNumberInputController.text.isEmpty
                ? "XXXX XXXX XXXX 1234"
                : _cardNumberInputController.text,
            style: TextStyle(
              fontFamily: 'OCRA',
              color: Colors.white,
              fontSize: 19,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                ),
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 8.0,
                  color: cardLabelColors[cardBrand]!.withOpacity(0.5),
                ),
              ],
            ),
          ),
        )),
        Positioned(
            left: 16,
            bottom: 30,
            child: Wrap(
              direction: Axis.vertical,
              spacing: 3.6,
              children: [
                Text(
                  'CARD HOLDER',
                  style: GoogleFonts.inconsolata(
                    color: cardLabelColors[cardBrand],
                    fontSize: 11,
                  ),
                ),
                Text(
                  _cardHolderInputController.text.isEmpty
                      ? "JOHN DOE"
                      : _cardHolderInputController.text.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'OCRA',
                    color: Colors.white,
                    fontSize: 14,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                      ),
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 8.0,
                        color: cardLabelColors[cardBrand]!.withOpacity(0.5),
                      ),
                    ],
                  ),
                )
              ],
            )),
        Positioned(
            right: 18,
            bottom: 30,
            child: Wrap(
              direction: Axis.vertical,
              spacing: 3.6,
              children: [
                Text(
                  'EXPIRES',
                  style: GoogleFonts.inconsolata(
                    color: cardLabelColors[cardBrand],
                    fontSize: 11,
                  ),
                ),
                Text(
                  _expiryDateInputController.text.isEmpty
                      ? "MM/YY"
                      : _expiryDateInputController.text,
                  style: TextStyle(
                    fontFamily: 'OCRA',
                    color: Colors.white,
                    fontSize: 14,
                    shadows: <Shadow>[
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 3.0,
                        color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                      ),
                      Shadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 8.0,
                        color: cardLabelColors[cardBrand]!.withOpacity(0.5),
                      ),
                    ],
                  ),
                )
              ],
            ))
      ],
    );

    Widget cardBackSide = Stack(
      children: [
        currentCardBackSideImage,
        Positioned(
            right: 27,
            top: (MediaQuery.of(context).size.width - 60) * .22,
            child: Text(
              _cvvInputController.text.isEmpty
                  ? "123"
                  : _cvvInputController.text,
              style: GoogleFonts.inconsolata(
                color: Colors.black,
                fontSize: 18,
              ),
            ))
      ],
    );

    Widget cardHoldingSpace = Container(
        // width: double.infinity,
        width: MediaQuery.of(context).size.width,
        height: 9 * MediaQuery.of(context).size.width / 16,
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: CardFlipper(
            cardFlippingController: cardFlipper,
            transitionDuration: Duration(milliseconds: 960),
            frontSide: cardFrontSide,
            backSide: cardBackSide));

    Widget cardInputFieldsSpace = Container(
      // width: double.infinity,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      height: 100,
      color: Colors.white,
      child: FocusScope(
          node: cardDetailsFocusNodes,
          child: ScrollablePositionedList.separated(
            scrollDirection: Axis.horizontal,
            itemScrollController: _cardInputDataController,
            physics: NeverScrollableScrollPhysics(),
            itemCount: cardInputFields.length,
            itemBuilder: (context, index) {
              return Opacity(
                opacity: _currentStep == index ? 1 : 0.3,
                child: cardInputFields[index],
              );
            },
            separatorBuilder: (context, index) => SizedBox(
              width: 14,
            ),
          )),
    );
    Widget goBackToPreviousStepButton = TextButton(
        onPressed: backToPreviousStep,
        child: Text(
          "BACK",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ));
    Widget goToNextStepButton = TextButton(
        onPressed: proceedToNextStep,
        child: Text(
          "NEXT",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ));
    Widget completedAllStepsButton = TextButton(
        onPressed: _tryAddingCard,
        child: Text(
          "DONE",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ));

    Widget cardInputNavigationButtons = Container(
      color: Color.fromARGB(255, 40, 4, 148),  // width: double.infinity,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(0),
      child: _currentStep < 3
          ? Wrap(
              alignment: WrapAlignment.spaceAround,
              children: [
                if (_currentStep > 0) goBackToPreviousStepButton,
                goToNextStepButton
              ],
            )
          : _cardHolderInputController.text.isNotEmpty
              ? completedAllStepsButton
              : goBackToPreviousStepButton,
    );
    
