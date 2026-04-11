import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About Us & Terms',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 LOGO SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF5F7FA),
                    Color(0xFFE4ECF7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo/hunzo_main_logo.png',
                    height: 90,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Powered by HungZo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  // 🔹 DYNAMIC APP VERSION
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Text(
                      _appVersion.isEmpty
                          ? 'Loading version...'
                          : 'App Version $_appVersion',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 CONTENT CARD (FULL WIDTH)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 16),
                    child: Html(
                      data: _htmlContent,
                      style: {
                        "body": Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        "h2": Style(
                          fontSize: FontSize(20),
                          fontWeight: FontWeight.bold,
                          margin: Margins.only(bottom: 12, top: 12),
                        ),
                        "p": Style(
                          fontSize: FontSize(14.5),
                          lineHeight: LineHeight(1.7),
                          margin: Margins.only(bottom: 12),
                        ),
                        "ul": Style(
                          padding: HtmlPaddings.only(left: 18),
                          margin: Margins.zero,
                        ),
                        "li": Style(
                          fontSize: FontSize(14.5),
                          lineHeight: LineHeight(1.7),
                          margin: Margins.only(bottom: 10),
                        ),
                        "hr": Style(
                          margin: Margins.symmetric(vertical: 16),
                        ),
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const String _htmlContent = """
<h2>Hungzo – About Us</h2>

<p>
Hungzo is a next-generation mobile application designed to transform the way
restaurants source their raw food materials. Built with the realities of the
food and hospitality industry in mind, Hungzo connects verified restaurants
directly with trusted suppliers, creating a seamless, transparent, and
efficient supply chain ecosystem.
</p>

<p>
In today’s fast-paced restaurant environment, timely restocking, quality
assurance, and cost control are critical. Hungzo addresses these challenges by
eliminating unnecessary middlemen and reducing friction in procurement.
Through our platform, restaurants can easily browse suppliers, compare prices,
place orders, and track deliveries—all from a single, intuitive mobile app.
</p>

<p>
At Hungzo, trust and verification are at the core of our ecosystem. Every
restaurant and supplier on the platform undergoes a verification process to
ensure reliability, quality, and compliance. This builds confidence on both
sides and enables long-term, dependable partnerships.
</p>

<p>
Our platform supports secure digital payments, ensuring that transactions are
fast, safe, and fully traceable. Restaurants gain clarity over pricing and
payments, while suppliers benefit from quicker settlements and reduced
operational overhead. Real-time order status updates and efficient delivery
tracking provide complete visibility from order placement to doorstep delivery,
minimizing uncertainty and delays.
</p>

<p>
Hungzo is more than just a marketplace—it is a supply chain enabler. By
streamlining procurement, improving communication, and increasing transparency,
we help restaurants focus on what they do best: delivering great food and
experiences to their customers. At the same time, suppliers gain direct access
to genuine business demand, helping them scale efficiently.
</p>

<p>
Driven by technology, transparency, and trust, Hungzo aims to become the
backbone of restaurant supply management—ensuring smoother operations, reduced
wastage, and timely restocking for food businesses of all sizes.
</p>

<hr/>

<h2>Hungzo App – Terms & Conditions</h2>

<ul>
  <li>Users must register with accurate, complete, and up-to-date information.</li>
  <li>Only verified restaurants and approved suppliers are allowed to use the platform.</li>
  <li>Users are responsible for maintaining the confidentiality of their login credentials.</li>
  <li>Hungzo acts as a technology platform and does not directly sell or manufacture food items.</li>
  <li>All product quality, quantity, and compliance are the responsibility of the supplier.</li>
  <li>Restaurants must review product details and prices carefully before placing orders.</li>
  <li>Once an order is confirmed, cancellation or modification is subject to supplier policies.</li>
  <li>Payments must be made through Hungzo’s secure payment system only.</li>
  <li>Hungzo is not liable for delays caused by unforeseen circumstances such as weather, strikes, or logistics issues.</li>
  <li>Delivery timelines are indicative and may vary based on location and availability.</li>
  <li>Users must not misuse the platform for fraudulent, illegal, or unethical activities.</li>
  <li>Hungzo reserves the right to suspend or terminate accounts violating platform policies.</li>
  <li>Pricing, availability, and offers are subject to change without prior notice.</li>
  <li>Any disputes between restaurants and suppliers should be resolved as per platform guidelines.</li>
  <li>Hungzo is not responsible for indirect losses, business interruptions, or damages.</li>
  <li>User data is handled as per Hungzo’s Privacy Policy and applicable data protection laws.</li>
  <li>Reviews and ratings must be genuine and free from abusive or misleading content.</li>
  <li>Hungzo may update or modify these Terms & Conditions at any time.</li>
  <li>Continued use of the app implies acceptance of revised Terms & Conditions.</li>
  <li>All legal matters are subject to the jurisdiction of applicable local laws.</li>
</ul>
""";
