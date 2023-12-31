USE [p_adagioRHEdman]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	
-- =============================================
CREATE PROCEDURE [RH].[spValidarImportacionPlazas]
    @dtImportacionPlazas [RH].[dtImportacionPlazas] READONLY,
	@IDUsuario int
AS
BEGIN
	
	declare 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    SELECT                    
		ip.IDPlaza,
		ip.CantidadPosiciones,
		ip.FechaInicio,
		ip.FechaFin,
		ip.IsTemporal ,
		ip.NivelSalarial,
		ip.ParentID,
		ip.ParentCodigo,
		ParentPlazaDescripcion= case when ip.ParentID != '' then 1 end ,

		tArea.Codigo [CodigoArea],
		tArea.Descripcion [DescripcionArea],
		tArea.IDArea [IDArea],

		tCentroCosto.Codigo [CodigoCentroCosto],
		tCentroCosto.IDCentroCosto,            
		tCentroCosto.Descripcion [DescripcionCentroCosto],                

		tClafCorporativa.Codigo [CodigoClasificacionCorporativa],                      
		tClafCorporativa.Descripcion [DescripcionClasificacionCorporativa],
		tClafCorporativa.IDClasificacionCorporativa [IDClasificacionCorporativa],

		tDepartamento.IDDepartamento [IDDepartamento],
		tDepartamento.Codigo [CodigoDepartamento],
		tDepartamento.Descripcion [DescripcionDepartamento],

		tDivision.IDDivision [IDDivision],
		tDivision.Codigo [CodigoDivision],
		tDivision.Descripcion [DescripcionDivision],

		tPrestacion.IDTipoPrestacion [IDPrestacion],
		tPrestacion.Codigo [CodigoPrestacion],
		tPrestacion.Descripcion [DescripcionPrestacion],

		tPuestos.IDPuesto [IDPuesto],
		tPuestos.Codigo [CodigoPuesto],
		JSON_VALUE(tPuestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) [DescripcionPuesto],

		tRegion.IDRegion [IDRegion],
		tRegion.Codigo [CodigoRegion],
		tRegion.Descripcion [DescripcionRegion],


		tRegPatronal.IDRegPatronal [IDRegistroPatronal],
		tRegPatronal.IDRegPatronal [CodigoRegistroPatronal],
		tRegPatronal.RegistroPatronal [DescripcionRegistroPatronal],

		tSucursal.IDSucursal [IDSucursal],
		tSucursal.Codigo [CodigoSucursal],
		tSucursal.Descripcion [DescripcionSucursal],
		tPlazas.Codigo [ParentCodigo],
		[MensajeError]= 
			case when isnull(ip.CantidadPosiciones,0) =0 then '<b>* Debe ingresar el numero de posiciones.</b><br>' else '' end+
			case when isnull(ip.IDPlaza,0) =0 then '<b>* Debe ingresar el ID Plaza.</b><br>' else '' end +                    
			case when isnull(tPuestos.IDPuesto,0) =0 then 
							case when isnull(ip.CodigoPuesto,'') = '' then '<b>* Debe ingresar el codigo del puesto.</b><br>' 
							else '<b>* No se ha encontrado el codigo del puesto.</b><br>'  end 
			else ''
			end +
			case when isnull(ip.FechaInicio,'1899-12-30') ='1899-12-30' then '<b>* Debe ingresar la fecha inicio.</b><br>' else '' end +
			case when isnull(ip.IsTemporal,'0') ='0' then '' else 
				case when isnull(ip.FechaFin,'1899-12-30') ='1899-12-30' then '<b>* Debe ingresar la fecha fin.</b><br>' else 
					case when ip.FechaInicio > ip.FechaFin    then '<b>* La fecha inicio no puede ser mayor a la fecha fin.</b><br>' else '' end                          
				end                        
			end+
			case when ip.ParentCodigo is null and ip.ParentID is null then '<b>* Debe ingresar el parent de la plaza.</b><br>' else '' end +
			case when ip.PosicionesJefes is null and ip.PosicionesJefesCodigo is null then '<b>* Debe ingresar al jefe de las posiciones</b><br>' else '' end                     
			,
		[Codigo]= case when isnull(ip.CantidadPosiciones,0) =0 then 1  else 0 end
    FROM @dtImportacionPlazas ip
        left join RH.tblCatArea tArea				on tArea.Codigo = ip.CodigoArea 
        left join RH.tblCatCentroCosto tCentroCosto	on tCentroCosto.Codigo = ip.CodigoCentroCosto 
        left join RH.tblCatClasificacionesCorporativas tClafCorporativa on tClafCorporativa.Codigo = ip.CodigoClasificacion 
        left join RH.tblCatDepartamentos tDepartamento		on tDepartamento.Codigo = ip.CodigoDepartamento 
        left join RH.tblCatDivisiones tDivision				on tDivision.Codigo =ip.CodigoDivision 
        left join RH.tblCatTiposPrestaciones tPrestacion	on tPrestacion.Codigo =ip.CodigoPrestacion 
        left join RH.tblCatPuestos tPuestos			on tPuestos.Codigo =ip.CodigoPuesto
        left join RH.tblCatRegiones tRegion			on tRegion.Codigo =ip.CodigoRegion            
        left join RH.tblCatRegPatronal tRegPatronal on tRegPatronal.RegistroPatronal =ip.CodigoRegPatronal
        left join RH.tblCatSucursales tSucursal		on tSucursal.Codigo =ip.CodigoSucursal
        left join RH.tblCatPlazas tPlazas			on tPlazas.Codigo =ip.ParentCodigo          
END
GO
