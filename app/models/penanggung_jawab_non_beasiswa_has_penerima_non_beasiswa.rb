class PenanggungJawabNonBeasiswaHasPenerimaNonBeasiswa < ApplicationRecord
  self.table_name = "penanggungjawabnonbeasiswa_has_penerimanonbeasiswa"
  belongs_to :penanggung_jawab_non_beasiswa, class_name: "PenanggungJawabNonBeasiswa"
  belongs_to :penerima_non_beasiswa, class_name: "PenerimaNonBeasiswa"

end
