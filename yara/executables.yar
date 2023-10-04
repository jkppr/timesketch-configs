rule executables_PE
{
  meta:
    description = "PE Executable"
    context = "True"

  condition:
    uint16(0) == 0x5A4D and
    uint32(uint32(0x3C)) == 0x00004550
}

rule executables_ELF
{
  meta:
    description = "Executable and Linking Format executable file (Linux/Unix)"
    context = "True"

  strings:
    $a = { 7F 45 4C 46 }

  condition:
    $a at 0
}

rule executables_MachO
{
  meta:
    description = "Mach-O binaries"
    context = "True"

  condition:
    uint32(0) == 0xfeedface or /* 32 bit */
    uint32(0) == 0xcefaedfe or /* NXSwapInt(MH_MAGIC */
    uint32(0) == 0xfeedfacf or /* 64 bit */
    uint32(0) == 0xcffaedfe or /* NXSwapInt(MH_MAGIC_64) */
    uint32(0) == 0xcafebabe or /* FAT, Java */
    uint32(0) == 0xbebafeca or /* NXSwapInt(FAT_MAGIC) */
    uint32(0) == 0xcafebabf or /* FAT 64 bit */
    uint32(0) == 0xbfbafeca    /* NXSwapLong(FAT_MAGIC_64) */
}
