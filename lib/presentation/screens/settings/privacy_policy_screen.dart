import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プライバシーポリシー')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プライバシーポリシー',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '最終更新日: 2024年',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '1. はじめに',
              content:
                  'VoiceCapsule（以下「本アプリ」）は、お子様の声を記録し、思い出として保存するためのアプリケーションです。本プライバシーポリシーでは、本アプリにおける個人情報の取り扱いについて説明します。',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '2. 収集する情報',
              content:
                  '本アプリは以下の情報を収集します：\n\n• お子様の名前\n• お子様の生年月日\n• 録音された音声データ\n• アプリの使用状況\n\nこれらの情報は、すべてお使いのデバイス内にローカルに保存され、外部サーバーには送信されません。',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '3. 情報の利用目的',
              content:
                  '収集した情報は、以下の目的で利用します：\n\n• 録音データの管理と再生\n• アプリの機能改善\n• ユーザーサポート',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '4. 情報の共有',
              content:
                  '本アプリは、お客様の個人情報を第三者と共有することはありません。すべてのデータはデバイス内にローカルに保存されます。',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '5. データの保存期間',
              content:
                  '録音データおよび個人情報は、お客様がアプリをアンインストールするまで、またはデータを削除するまで保存されます。',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '6. セキュリティ',
              content:
                  '本アプリは、お客様の情報を保護するために適切なセキュリティ対策を講じています。ただし、インターネットを介した情報伝送やデータ保存の方法に完全な安全性を保証することはできません。',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: '7. お問い合わせ',
              content:
                  '本プライバシーポリシーに関するご質問やご意見がございましたら、アプリ内のお問い合わせフォームよりご連絡ください。',
            ),
            const SizedBox(height: 24),
            Text(
              '※ これはプレースホルダーテキストです。実際のプライバシーポリシーは法的要件に基づいて作成してください。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
        ),
      ],
    );
  }
}
