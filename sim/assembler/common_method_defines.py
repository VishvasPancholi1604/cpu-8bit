def get_bit_field(value, msb, lsb):
    mask = (1 << (msb - lsb + 1)) - 1
    return (value >> lsb) & mask


def set_bit_field(value, msb, lsb, field_value):
    mask = (1 << (msb - lsb + 1)) - 1
    return (value & ~(mask << lsb)) | ((field_value & mask) << lsb)

