USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Asistencia].[fnGetIncapacidades]
(
	@IDEmpleado int,
	@FechaIni Date,
	@FechaFin Date
)
RETURNS @tblInca TABLE
(
	Numero Varchar(100),
	Duracion int,
	TipoIncapacidad Varchar(10),
	PagoSubsidioEmpresa bit
)
AS
BEGIN

	insert into @tblInca(Numero,Duracion,TipoIncapacidad,PagoSubsidioEmpresa)
	
		select IncaEmp.Numero,COUNT(*) as Duracion,
		--Cambio por error de timbrado DIANA, validado con Joseph
		--COALESCE(TI.Codigo,2),
		TI.Codigo,
		IncaEmp.PagoSubsidioEmpresa
			from Asistencia.tblIncidenciaEmpleado IE
				Left Join Asistencia.tblCatIncidencias I
					on IE.IDIncidencia = I.IDIncidencia
				Left Join Asistencia.tblIncapacidadEmpleado IncaEmp
					on IE.IDIncapacidadEmpleado = IncaEmp.IDIncapacidadEmpleado	
			LEFT join Sat.tblCatTiposIncapacidad TI
				on IncaEmp.IDTipoIncapacidad = TI.IDTIpoIncapacidad
		where I.IDIncidencia = 'I'
			AND IE.IDEmpleado = @IDEmpleado
			AND IE.Fecha Between @FechaIni and @FechaFin
		GROUP BY IncaEmp.Numero,TI.Codigo,IncaEmp.PagoSubsidioEmpresa

		return;
		
END
GO
