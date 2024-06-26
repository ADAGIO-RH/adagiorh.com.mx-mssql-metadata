USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spGenerarSuaReporteDatosAfiliatorios]
(
@FechaIni date = '1900-01-01',              
 @Fechafin date = '9999-12-31',              
 @AfectaIDSE bit = 0,
 @FechaIDSE date = '9999-12-31',   
  @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
  @IDUsuario int
)
AS
BEGIN
	
	declare @IDRegPatronal int
	 , @dtEmpleados RH.dtEmpleados;

	select top 1 @IDRegPatronal = item from app.Split((select top 1 value from @dtFiltros where Catalogo = 'RegPatronales'),',')

	   insert into @dtEmpleados      
   exec [RH].[spBuscarEmpleados] @FechaIni = @FechaIni, @Fechafin= @Fechafin, @dtFiltros = @dtFiltros, @IDUsuario= @IDUsuario      
    

	select  [App].[fnAddString](11,ISNULL(rp.RegistroPatronal,''),'',2) -- REGISTRO PATRONAL IMSS
	    -- + [App].[fnAddString](2,ISNULL(' ',''),'',2)
		   + [App].[fnAddString](11,ISNULL(e.IMSS,''),'',2) -- NUMERO DE SEGURIDAD SOCIAL
		   + [App].[fnAddString](5,ISNULL(0,''),'0',2) -- Código Postal 
		   + [App].[fnAddString](8,ISNULL(case when e.FechaNacimiento is not null then FORMAT(e.FechaNacimiento, 'ddMMyyyy') else '' end,''),'0',2) -- Fecha de Movimiento
		   + [App].[fnAddString](25,ISNULL(e.MunicipioNacimiento,''),' ',2) -- Lugar de nacimiento
		   + [App].[fnAddString](2, ISNULL(	CASE    WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'AGUASCALIENTES'		THEN 'AS'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'BAJA CALIFORNIA'			THEN 'BC'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'BAJA CALIFORNIA SUR'		THEN 'BS'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'CAMPECHE'				THEN 'CC'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'CHIAPAS'					THEN 'CS'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'CHIHUAHUA'				THEN 'CH'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'COAHUILA'				THEN 'CL'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'COLIMA'					THEN 'CM'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'DISTRITO FEDERAL'		THEN 'DF'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'DURANGO'					THEN 'DG'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'GUANAJUATO'				THEN 'GT'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'GUERRERO'				THEN 'GR'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'HIDALGO'					THEN 'HG'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'JALISCO'					THEN 'JC'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'MEXICO'					THEN 'MC'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'MICHOACAN'				THEN 'MN'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'MORELOS'					THEN 'MS'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'NAYARIT'					THEN 'NT'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'NUEVO LEON'				THEN 'NL'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'OAXACA'					THEN 'OC'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'PUEBLA'					THEN 'PL'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'QUERETARO'				THEN 'QT'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'QUINTANA ROO'			THEN 'QR'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'SAN LUIS POTOSI'			THEN 'SP'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'SINALOA'					THEN 'SL'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'SONORA'					THEN 'SR'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'TABASCO'					THEN 'TC'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'TAMAULIPAS'				THEN 'TS'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'TLAXCALA'				THEN 'TL'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'VERACRUZ'				THEN 'VZ'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'YUCATÁN'					THEN 'YN'
													WHEN ISNULL(es.NombreEstado,e.EstadoNacimiento) = 'ZACATECAS'				THEN 'ZS'
													ELSE 'NE' END,''),'0',2) -- Clave del lugar de nacimiento
					+ [App].[fnAddString](3,ISNULL(e.UMF,''),'0',2) -- UMF
					+ [App].[fnAddString](12,ISNULL(o.Descripcion,''),' ',2) -- OCUPACION
					+ [App].[fnAddString](1,ISNULL(CASE WHEN e.Sexo = 'MASCULINO' THEN 'M' ELSE 'F'END,''),' ',2) -- SEXO
					+ [App].[fnAddString](1,2,'0',2) -- TIPO SALARIO
					+ [App].[fnAddString](1,0,'0',2) -- HORAS
	from @dtEmpleados e
		inner join rh.tblCatRegPatronal rp
			on e.IDRegPatronal = rp.IDRegPatronal
		left join sat.tblCatEstados es
			on es.IDEstado = e.IDEstadoNacimiento
		left join RH.tblSaludEmpleado se
			on se.IDEmpleado = e.IDEmpleado
		left join RH.tblCatPuestos p
			on e.IDPuesto = p.IDPuesto
		left join STPS.tblCatOcupaciones o
			on o.IDOcupaciones = p.IDOcupacion


END
GO
