USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spBuscarConfigAsignacionesPredeterminadas](
	@IDConfigAsignacionPredeterminada int = 0
	,@IDUsuario int 
) as

	select 
		cap.IDConfigAsignacionPredeterminada
		,isnull(d.Descripcion,'Sin asignar') as Departamento
		,isnull(cap.IDDepartamento,0) as IDDepartamento 
		,isnull(s.Descripcion,'Sin asignar') as Sucursal
		,isnull(cap.IDSucursal,0) as IDSucursal
		,isnull(p.Descripcion,'Sin asignar') as Puesto
		,isnull(cap.IDPuesto,0) as IDPuesto
		,isnull(cc.Descripcion,'Sin asignar') as ClasificacionCorporativa
		,isnull(cap.IDClasificacionCorporativa,0) as IDClasificacionCorporativa
		,isnull(div.Descripcion,'Sin asignar') as Division
		,isnull(cap.IDDivision,0) as IDDivision
		,isnull(tn.Descripcion,'Sin asignar') as TipoNomina
		,isnull(cap.IDTipoNomina,0) as IDTipoNomina
		,isnull(cap.IDsJefe, 'Jefes no definidos') as IDsJefe 
		,Jefes = ISNULL( STUFF(  
		   (   SELECT ', '+ CONVERT(NVARCHAR(100), NOMBRECOMPLETO)   
			FROM RH.tblEmpleadosMaster with (nolock)
			WHERE IDEmpleado in (select cast(rtrim(ltrim(item)) as int) from app.Split(cap.IDsJefe,','))  
			ORDER BY NOMBRECOMPLETO  asc  
			FOR xml path('')  
		   )  
		   , 1  
		   , 1  
		   , ''), 'Jefes no definidos')  
		,isnull(cap.IDsLectores,'Lectores no defininos') as IDsLectores
		,Lectores = ISNULL( STUFF(  
		   (   SELECT ', '+ CONVERT(NVARCHAR(100), Lector)   
			FROM Asistencia.tblLectores with (nolock)
			WHERE IDLector in (select cast(rtrim(ltrim(item)) as int) from app.Split(cap.IDsLectores,','))  
			ORDER BY Lector  asc  
			FOR xml path('')  
		   )  
		   , 1  
		   , 1  
		   , ''), 'Lectores no definidos')  
		,isnull(cap.IDsSupervisores,'Supervisores no definidos') as IDsSupervisores
		,Supervisores = ISNULL( STUFF(  
		   (   SELECT ', '+ CONVERT(NVARCHAR(100), NOMBRECOMPLETO)   
			FROM RH.tblEmpleadosMaster with (nolock)
			WHERE IDEmpleado in (select cast(rtrim(ltrim(item)) as int) from app.Split(cap.IDsSupervisores,','))  
			ORDER BY NOMBRECOMPLETO  asc  
			FOR xml path('')  
		   )  
		   , 1  
		   , 1  
		   , ''), 'Supervisores no definidos')  
		,isnull(cap.Factor,0) as Factor
		,isnull(cap.IDUsuario,0) as IDUsuario
	from [RH].[tblConfigAsignacionesPredeterminadas] cap with (nolock)
		left join RH.tblCatDepartamentos d on d.IDDepartamento = cap.IDDepartamento
		left join RH.tblCatSucursales s on s.IDSucursal = cap.IDSucursal
		left join RH.tblCatPuestos p on p.IDPuesto = cap.IDPuesto
		left join RH.tblCatClasificacionesCorporativas cc on cc.IDClasificacionCorporativa = cap.IDClasificacionCorporativa
		left join RH.tblCatDivisiones div on div.IDDivision = cap.IDDivision
		left join Nomina.tblCatTipoNomina tn on tn.IDTipoNomina = cap.IDTipoNomina
	where (cap.IDConfigAsignacionPredeterminada = @IDConfigAsignacionPredeterminada or @IDConfigAsignacionPredeterminada = 0)
GO
