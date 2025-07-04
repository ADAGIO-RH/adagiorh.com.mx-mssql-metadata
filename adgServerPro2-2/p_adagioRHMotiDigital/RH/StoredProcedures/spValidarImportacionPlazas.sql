USE [p_adagioRHMotiDigital]
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
    @Filtro varchar(255),
    @IDReferencia int ,
    @IDCliente int ,
	@IDUsuario int
AS
BEGIN
	
	declare 
		@IDIdioma varchar(20),
        @IDOrganigrama int 	;


        



	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
    select @IDOrganigrama= IDOrganigrama from rh.tblCatOrganigramas where IDReferencia=@IDReferencia and Filtro=@Filtro

    -- declare @dtImportacionPlazasTemp as [RH].[dtImportacionPlazas];
    declare @dtIDPlazasRepetidas as table (
        IDPlaza int
    )

    insert into @dtIDPlazasRepetidas
    select IDPlaza from (
        select IDPlaza, count(*) as total from @dtImportacionPlazas            
        GROUP by IDPlaza 
    ) as repetidos
    where total> 1 
                

	-- Nota 
    -- El -1  es para referirse a codigos que no se ingresaron por parte del usuario
    -- El -2 es para referirse a codigos que si ingreso el usuario pero no se encontraron en sus respectivos catalogos
    -- El -3 mensaje personalizado para el tipo de nomina.

    SELECT                    
		isnull(ip.IDPlaza,-1) as IDPlaza,        
		ip.CantidadPosiciones,
		ip.FechaInicio,
		ip.FechaFin,
		ip.IsTemporal ,
		ip.NivelSalarial,
		ip.ParentID,
		ip.ParentCodigo,
		ParentPlazaDescripcion= case when ip.ParentID != '' then 1 end ,

        tArea.IDArea [IDArea],
		tArea.Codigo [CodigoArea],
        CASE
            WHEN  isnull(ip.CodigoArea,'')  = '' then  '-1' 
            WHEN  tArea.IDArea is null then  '-2' 
            ELSE  JSON_VALUE(tArea.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
            end as  [DescripcionArea] ,		
		
        tCentroCosto.IDCentroCosto,            
		tCentroCosto.Codigo [CodigoCentroCosto],
        CASE
            WHEN  isnull(ip.CodigoCentroCosto,'')  = '' then  '-1' 
            WHEN  tCentroCosto.IDCentroCosto is null then  '-2' 
            ELSE JSON_VALUE(tCentroCosto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
            end as  [DescripcionCentroCosto] ,		
		
		
        tClafCorporativa.IDClasificacionCorporativa [IDClasificacionCorporativa],
		tClafCorporativa.Codigo [CodigoClasificacionCorporativa],                      
        CASE
            WHEN  isnull(ip.CodigoClasificacion,'')  = '' then  '-1' 
            WHEN  tClafCorporativa.IDClasificacionCorporativa is null then  '-2' 
            --ELSE  tClafCorporativa.Descripcion end as  [DescripcionClasificacionCorporativa] ,		
			ELSE  JSON_VALUE(tClafCorporativa.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')) end as  [DescripcionClasificacionCorporativa] ,		
		

		tDepartamento.IDDepartamento [IDDepartamento],
        tDepartamento.Codigo [CodigoDepartamento],
        CASE
            WHEN  isnull(ip.CodigoDepartamento,'')  = '' then  '-1' 
            WHEN  tDepartamento.IDDepartamento is null then  '-2' 
            ELSE  JSON_VALUE(tDepartamento.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))end as  [DescripcionDepartamento] ,		
		

		tDivision.IDDivision [IDDivision],        
        tDivision.Codigo [CodigoDivision],
        CASE
            WHEN  isnull(ip.CodigoDivision,'')  = '' then  '-1' 
            WHEN  tDivision.IDDivision is null then  '-2' 
            ELSE  JSON_VALUE(tDivision.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))end  as  [DescripcionDivision] ,
		

		tPrestacion.IDTipoPrestacion [IDPrestacion],
        tPrestacion.Codigo [CodigoPrestacion],
        CASE
            WHEN  isnull(ip.CodigoPrestacion,'')  = '' then  '-1' 
            WHEN  tPrestacion.IDTipoPrestacion is null then  '-2' 
            ELSE  JSON_VALUE(tPrestacion.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))end as  [DescripcionPrestacion] ,				
		
		tPuestos.IDPuesto [IDPuesto],
		tPuestos.Codigo [CodigoPuesto],
        CASE
            WHEN  isnull(ip.CodigoPuesto,'')  = '' then  '-1' 
            WHEN  tPuestos.IDPuesto is null then  '-2' 
            ELSE 
                concat( tPuestos.Codigo, ' - ' ,JSON_VALUE(tPuestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) )                         
            end as  [DescripcionPuesto] ,	
		

		tRegion.IDRegion [IDRegion],
		tRegion.Codigo [CodigoRegion],
        CASE
            WHEN  isnull(ip.CodigoRegion,'')  = '' then  '-1' 
            WHEN  tRegion.IDRegion is null then  '-2' 
            ELSE  JSON_VALUE(tRegion.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  end as  [DescripcionRegion] ,				

        tRazonSocial.IDEmpresa [IDRazonSocial],
		tRazonSocial.[RFC] [CodigoRazonSocial],
        CASE
            WHEN  isnull(ip.CodigoRazonSocial,'')  = '' then  '-1' 
            WHEN  tRazonSocial.IDEmpresa is null then  '-2' 
            ELSE  tRazonSocial.NombreComercial end as  [DescripcionRazonSocial] ,				
		

        tTabuladorSalarial.IDNivelSalarial [IDNivelSalarial],
        tTabuladorSalarial.Nombre  [NombreNivelSalarial],
        tTabuladorSalarial.Nivel [NivelSalarial],


		tRegPatronal.IDRegPatronal [IDRegistroPatronal],
		tRegPatronal.IDRegPatronal [CodigoRegistroPatronal],
        CASE
            WHEN  isnull(ip.CodigoRegPatronal,'')  = '' then  '-1' 
            WHEN  tRegPatronal.IDRegPatronal is null then  '-2' 
            ELSE  tRegPatronal.RegistroPatronal end as  [DescripcionRegistroPatronal] ,			

		tSucursal.IDSucursal [IDSucursal],
		tSucursal.Codigo [CodigoSucursal],
        CASE
            WHEN  isnull(ip.CodigoSucursal,'')  = '' then  '-1' 
            WHEN  tSucursal.IDSucursal is null then  '-2' 
            ELSE  tSucursal.Descripcion end as  [DescripcionSucursal] ,					


        tPerfiles.IDPerfil [IDPerfil],
        CASE
            WHEN  isnull(ip.NombrePerfilUsuario,'')  = '' then  '-1' 
            WHEN  tPerfiles.IDPerfil is null then  '-2' 
            ELSE  tPerfiles.Descripcion end as  [NombrePerfilUsuario] ,					

        CASE
            WHEN  isnull(ip.DescripcionTipoNomina,'')  = '' then  '-1' 
            WHEN  tTipoNomina.IDTipoNomina is null then  '-3' 
            ELSE  tTipoNomina.Descripcion end as  [DescripcionTipoNomina] ,					            
        tTipoNomina.IDTipoNomina [IDTipoNomina],


        isnull(tNivelEmpresarial.IDNivelEmpresarial,0) [IDNivelEmpresarial],        
        isnull(tNivelEmpresarial.Nombre,'') [NombreNivelEmpresarial],
        isnull(tNivelEmpresarial.Orden,0) [OrdenNivelEmpresarial],
        
		-- tPlazas.Codigo [ParentCodigo],
        
        ip.EsAsistente,
		[MensajeError]= ''+		
			CASE -- VALIDACIONES PARA EL CAMPO DE IDPLAZA
				WHEN isnull(ip.IDPlaza,0) =0 then 
					'* Debe ingresar el IDPlaza. <b>(Columna A)</b><br>' 
				WHEN exists(select top 1 1 from @dtIDPlazasRepetidas rd where rd.IDPlaza=ip.IDPlaza )  then 
                	'* El <b> IDPlaza '+isnull(cast(ip.IDPlaza as varchar(5)),'')+' </b> esta asignada en mas de una fila, no se pueden repetir los valores de <b>IDPlaza</b>. <b>(Columna A)</b><br>' 
				else '' 
			end +  

			CASE -- VALIDACIONES PARA EL CAMPO CODIGOPUESTO
				WHEN isnull(ip.CodigoPuesto,'') = '' then 
					'* Debe ingresar el código del puesto.  <b>(Columna B)</b><br>' 
				WHEN isnull(tPuestos.IDPuesto,0) = 0 then 
					'* No se ha encontrado el código del puesto.  <b>Codigo Ingresado:</b> <i>'+isnull(ip.CodigoPuesto,'')+'</i> <br>'  
				else '' 
			end + 

			CASE  -- Validaciones PARA EL CAMPO Cantidad de posiciones
				WHEN isnull(ip.CantidadPosiciones,0) =0 then 
					'* Debe ingresar la cantidad de posiciones. <b>(Columna D)</b><br>' 
				else '' 
			end + 
			CASE  
				when  (ip.ParentID  is not null and isnull(ip.ParentCodigo,'') =''  and ip.PosicionesJefes is null and isnull(ip.PosicionesJefesCodigo,'') <> '' ) then 					  
					'* No es posible tener valores en las columnas <b>ParentID</b> y <b>PosicionesJefeCodigo</b> en la misma fila.'+
					' Para resolver este error debe asignar solamente las columnas <b>(ParentID y PosicionesJefe) para plazas y posiciones aun no existentes </b> o <b>(ParentCodigo y PosicionJefeCodigo para plazas y posiciones existentes</b>.<br>'
					-- ' Debe asignar <b>(ParentID y PosicionesJefe)</b> o <b>(ParentCodigo y PosicionJefeCodigo</b>' 

				when  (ip.ParentID  is null and isnull(ip.ParentCodigo,'') <> ''  and ip.PosicionesJefes is not null and isnull(ip.PosicionesJefesCodigo,'') = '' ) then 					  
					'* No es posible tener valores en las columnas <b>ParentCodigo</b> y <b>PosicionesJefe</b> en la misma fila.'+
					' Para resolver este error debe asignar solamente las columnas <b>(ParentID y PosicionesJefe) para plazas y posiciones aun no existentes </b> o <b>(ParentCodigo y PosicionJefeCodigo para plazas y posiciones existentes</b>.<br>'
				else	
					CASE -- Validaciones para el Parent de la plaza (PARENT ID Y PARENT CODIGO)
						WHEN isnull(ip.ParentCodigo,'') ='' and ip.ParentID is null then 
							'* Debe asignar un parent a la plaza.<br>'+ 
							'- <b>Columna E para plazas no existentes.</b><br>'+ 
							'- <b>Columna F para plazas existentes.</b>'+ 
							'<br>' 
						WHEN ISNULL(ip.ParentCodigo,'') <> '' and ip.ParentID is not null     then 			
							'* No es posible tener valores en las columnas <b>ParentID</b>  y <b>ParentCodigo</b> en la misma fila.<br>'+ 
							'- <b> ParentID</b> es para relacionar plazas del mismo archivo.<br>'+ 
							'- <b> ParentCodigo</b> es para relacionar plazas existentes.<br>'					
						WHEN ip.ParentID = 0 then ''
						WHEN not exists(select top 1 1 from @dtImportacionPlazas where IDPlaza=ip.ParentID)  and isnull(ip.ParentCodigo,'') ='' then 
							'* El <b>ParentID: '+isnull(cast(ip.ParentID as varchar(5)),'')+'</b> no se ha podido asociar con algún valor de la columna <b>IDPlaza</b>.'+
							' Esto es ocasionado debido a que no se encuentra la <b>IDPlaza: '+isnull(cast(ip.ParentID as varchar(5)),'')+' en el archivos importado.</b> <br>'
						WHEN isnull(tPlazas.IDPlaza,0)=0 and ip.ParentID is null then 
							'* El código de la plaza <b>'+isnull(ip.ParentCodigo,'')+'</b> no se encuentra en el sistema. verifique que el código sea correcto.<br>' 
						else ''  
					end + 
					CASE -- Validaciones para el Parent de la posicion (PosicionJefe,PosicionJefeCodigo)
						when ip.PosicionesJefes is null and isnull(ip.PosicionesJefesCodigo,'') ='' then  
							'* Debe asignar un jefe para las nuevas posiciones.<br>'+ 
							'- <b>Columna G para posiciones no existentes.</b><br>'+ 
							'- <b>Columna H para posiciones existentes.</b><br>' 
						when ip.PosicionesJefes is not null and isnull(ip.PosicionesJefesCodigo,'') <> ''     then 
                			'* No es posible tener valores en las columnas <b>Posiciones Jefe (G)</b>  y <b>Posiciones jefe codigo (H)</b> en la misma fila.<br>'+ 
                			'  - <b> Posiciones Jefe (G)</b> es para relacionar posiciones del mismo archivo.<br>'+ 
                			'  - <b> Posiciones jefe codigo (H)</b> es para relacionar posiciones existentes.<br>'	
						WHEN tPlazas.IDPlaza  is not null and tPosiciones.IDPosicion is null and tPosicionesTemp.IDPosicion is not null then 
						 	'* El código de la posición <b>'+isnull(ip.PosicionesJefesCodigo,'')+'</b> existe, pero no pertenece a la plaza '+isnull(ip.ParentCodigo,'')+'.<br>'	
						WHEN tPosicionesTemp.IDPosicion is null  and ip.PosicionesJefes is null  then 
						 	'* El código de la posición <b>'+isnull(ip.ParentCodigo,'')+'</b> no existe.<br>'	

						WHEN isnull(ip.PosicionesJefesCodigo,'')='' and isnull(tPlazaParentID.CantidadPosiciones,0) >= 1  and not (ip.PosicionesJefes between 1 and tPlazaParentID.CantidadPosiciones)   then 
						 	'* El rango permitido para la columna "Posiciones Jefe" debe estar entre <b> 1 y '+ cast(tPlazaParentID.CantidadPosiciones as varchar(10))+' (Cantidad de Posiciones de la plaza padre) </b>'					 
						else ''
					end      
			end +																		 
                                                                                                                    
			CASE when isnull(ip.FechaInicio,'1899-12-30') ='1899-12-30' then '* Debe ingresar la fecha inicio. <b>(Columna V)</b><br>' else '' end +
                CASE when isnull(ip.IsTemporal,'0') ='0' then '' else 
				CASE when isnull(ip.FechaFin,'1899-12-30') ='1899-12-30' then '* Debe ingresar la fecha fin. <b>(Columna W)</b><br>' else 
					case when ip.FechaInicio > ip.FechaFin    then '* La <b>fecha inicio</b> no puede ser mayor a la <b>fecha fin</b>.<br>' else '' end                          
				end                        
			end             
			,
		[Codigo]= case when isnull(ip.CantidadPosiciones,0) =0 then 1  else 0 end
    FROM @dtImportacionPlazas ip
        left join RH.tblCatArea tArea				on tArea.Codigo = ip.CodigoArea 
        left join RH.tblCatCentroCosto tCentroCosto	on tCentroCosto.Codigo = ip.CodigoCentroCosto 
        left join RH.tblCatClasificacionesCorporativas tClafCorporativa on tClafCorporativa.Codigo = ip.CodigoClasificacion 
        left join RH.tblCatDepartamentos tDepartamento		on tDepartamento.Codigo = ip.CodigoDepartamento 
        left join RH.tblCatDivisiones tDivision				on tDivision.Codigo =ip.CodigoDivision 
        left join RH.tblEmpresa tRazonSocial				on tRazonSocial.RFC =ip.CodigoRazonSocial
        left join RH.tblCatTiposPrestaciones tPrestacion	on tPrestacion.Codigo =ip.CodigoPrestacion 
        left join RH.tblCatPuestos tPuestos			    on tPuestos.Codigo =ip.CodigoPuesto
        LEFT JOIN RH.tblTabuladorSalarial tTabuladorSalarial on tTabuladorSalarial.Nivel=ip.NivelSalarial and tTabuladorSalarial.Nombre=ip.NombreNivelSalarial
        left join RH.tblCatRegiones tRegion			    on tRegion.Codigo =ip.CodigoRegion            
        left join RH.tblCatRegPatronal tRegPatronal     on tRegPatronal.RegistroPatronal =ip.CodigoRegPatronal
        left join RH.tblCatSucursales tSucursal		    on tSucursal.Codigo =ip.CodigoSucursal
        left join Seguridad.tblCatPerfiles tPerfiles    on tPerfiles.Descripcion =ip.NombrePerfilUsuario
        left join RH.tblCatPlazas tPlazas			    on tPlazas.Codigo =ip.ParentCodigo and tPlazas.IDOrganigrama=@IDOrganigrama
		left join RH.tblCatPosiciones tPosiciones on tPosiciones.Codigo=ip.PosicionesJefesCodigo and tPosiciones.IDPlaza=tPlazas.IDPlaza
		left join  (
                select  po.* from RH.tblCatPosiciones po
                inner join rh.tblCatPlazas p on po.IDPlaza=p.IDPlaza and p.IDOrganigrama=@IDOrganigrama
        )  tPosicionesTemp on tPosicionesTemp.Codigo =ip.PosicionesJefesCodigo   
        left join RH.tblCatNivelesEmpresariales tNivelEmpresarial on tNivelEmpresarial.Nombre=ip.NombreNivelEmpresarial
        left join Nomina.tblCatTipoNomina tTipoNomina on tTipoNomina.IDCliente =@IDCliente and tTipoNomina.Descripcion=ip.DescripcionTipoNomina
		LEFT JOIN @dtImportacionPlazas tPlazaParentID on tPlazaParentID.IDPlaza=ip.ParentID
        order by  MensajeError desc, ip.IDPlaza
END
GO
