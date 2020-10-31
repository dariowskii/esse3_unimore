import 'package:Esse3/constants.dart';
import 'package:flutter/material.dart';
import 'package:Esse3/utils/widgets.dart';

class LibrettoPage extends StatefulWidget {
  final Map libretto;

  LibrettoPage({@required this.libretto});

  @override
  _LibrettoPageState createState() => _LibrettoPageState();
}

class _LibrettoPageState extends State<LibrettoPage> {
  double _mediaPondDouble = 0, _mediaAritDouble = 0;
  int _votoLaureaInt, _cfuAccumulati = 0, _esamiConCfu = 0, _cfuMediaPond = 0;
  double _votoLaureaDouble;

  void _calcMedie(){
    for (int i = 0; i < widget.libretto["totali"]; i++) {
      if (widget.libretto["voti"][i] != "") {
        if( widget.libretto["voti"][i] != "IDONEO" && widget.libretto["voti"][i] != "APPR"){
          if (widget.libretto["voti"][i] == "30 LODE"){
            _mediaPondDouble += (double.parse(widget.libretto["crediti"][i]) * 30);
            _mediaAritDouble += 30;
          } else {
            _mediaPondDouble += (double.parse(widget.libretto["crediti"][i]) * double.parse(widget.libretto["voti"][i]));
            _mediaAritDouble += double.parse(widget.libretto["voti"][i]);
          }
          _esamiConCfu++;
          _cfuMediaPond += int.parse(widget.libretto["crediti"][i]);
        }
        _cfuAccumulati += int.parse(widget.libretto["crediti"][i]);
      }
    }
    _mediaPondDouble = double.parse((_mediaPondDouble / _cfuMediaPond).toStringAsPrecision(4));
    _mediaAritDouble = double.parse((_mediaAritDouble / _esamiConCfu).toStringAsPrecision(4));

    _votoLaureaInt = ((_mediaPondDouble * 110) / 30).floor();
    _votoLaureaDouble = (_mediaPondDouble * 110) / 30;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _calcMedie();
  }

  @override
  Widget build(BuildContext context) {
    final heightScreen = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            elevation: 2,
            collapsedHeight: 60,
            title: Text(
              "Esse3",
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop()),
            backgroundColor: kMainColor_darker,
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: kMainColor_darker,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Libretto",
                        style: TextStyle(
                          fontSize: width >= 390 ? 32 : 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Qui puoi vedere il tuo libretto universitario.",
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                          color: kMainColor_lighter,
                        ),
                        child: Center(
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: kMainColor_extraDark,
                              borderRadius: BorderRadius.all(Radius.circular(40)),
                            ),
                            child: Center(
                              child: Text(
                                "Tutti i tuoi esami",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(width >= 390 ? 20 : 15),
            sliver: SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Il tuo andamento",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(
                      color: Colors.black38,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Media Ponderata: $_mediaPondDouble / 30", style: const TextStyle(fontSize: 16)),
                            Text("Media Aritmetica: $_mediaAritDouble / 30", style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        BollinoAndamento(
                          icona: _mediaAritDouble >= 24
                              ? Icons.stars
                              : _mediaAritDouble >= 18 ? Icons.check_circle : Icons.warning,
                          colore: Colors.white,
                          testo: _mediaAritDouble >= 24 ? "fantastico!" : _mediaAritDouble >= 18 ? "vai così" : "attenzione!",
                          coloreSfondo: _mediaAritDouble >= 24
                              ? Colors.yellow[700]
                              : _mediaAritDouble >= 18 ? Colors.green[700] : Colors.yellow[700],
                          bordoOmbra: _mediaAritDouble >= 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ProiezioniConCFU(
                      votoLaureaDouble: _votoLaureaDouble,
                      votoLaureaInt: _votoLaureaInt,
                      cfuAccumulati: _cfuAccumulati,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(left: width >= 390 ? 20 : 15, right: width >= 390 ? 20 : 15, bottom: 20),
            sliver: widget.libretto["totali"] != 0
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      // ignore: missing_return
                      (context, index) {
                        return CardEsame(
                          nomeEsame: widget.libretto["materie"][index],
                          codiceEsame: widget.libretto["cod_materia"][index],
                          votoEsame: widget.libretto["voti"][index],
                          dataEsame: widget.libretto["data_esame"][index],
                          cfu: widget.libretto["crediti"][index],
                        );
                      },
                      childCount: widget.libretto["totali"],
                    ),
                  )
                : SliverToBoxAdapter(
                  child: Container(
                      height: heightScreen * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Image(
                            width: 200,
                            image: AssetImage('assets/img/nolibretto.png'),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Mmmm...",
                            style: const TextStyle(color: Colors.black87, fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Sembra tu non abbia esami nel libretto...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 22,
                            ),
                          )
                        ],
                      ),
                    ),
                ),
          ),
        ],
      ),
    );
  }
}
