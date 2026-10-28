"""Public evidence must preserve reviewed pixels and exclude hidden metadata."""
import hashlib
import json
import pathlib
import struct
import unittest
import zlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"


class PublicEvidence(unittest.TestCase):
    def setUp(self):
        self.manifest = json.loads((ASSETS / "evidence.json").read_text())

    def test_public_images_match_reviewed_hashes_and_png_chunks(self):
        for entry in self.manifest["images"]:
            with self.subTest(image=entry["file"]):
                path = ASSETS / entry["file"]
                self.assertTrue(path.resolve().is_relative_to(ASSETS.resolve()))
                data = path.read_bytes()
                self.assertEqual(hashlib.sha256(data).hexdigest(), entry["sha256"])
                self.assertEqual(data[:8], b"\x89PNG\r\n\x1a\n")
                offset, chunks = 8, []
                while offset < len(data):
                    length = struct.unpack(">I", data[offset:offset + 4])[0]
                    chunk = data[offset + 4:offset + 8]
                    body = data[offset + 8:offset + 8 + length]
                    crc = struct.unpack(">I", data[offset + 8 + length:offset + 12 + length])[0]
                    self.assertEqual(zlib.crc32(chunk + body) & 0xffffffff, crc)
                    self.assertIn(chunk, (b"IHDR", b"IDAT", b"IEND"), "Additional PNG metadata needs a separate publication review")
                    chunks.append(chunk)
                    offset += length + 12
                self.assertEqual(offset, len(data))
                self.assertEqual(chunks[0], b"IHDR")
                self.assertEqual(chunks[-1], b"IEND")

    def test_all_public_png_images_are_registered(self):
        registered = [entry["file"] for entry in self.manifest["images"]]
        self.assertEqual(len(registered), len(set(registered)))
        actual = {path.relative_to(ASSETS).as_posix() for path in ASSETS.rglob("*.png")}
        self.assertEqual(actual, set(registered))
        for entry in self.manifest["images"]:
            self.assertTrue(entry["scope"])
            self.assertTrue(entry["demonstrates"])
            self.assertTrue((ASSETS / entry["documentation"]).is_file())


if __name__ == "__main__":
    unittest.main()
