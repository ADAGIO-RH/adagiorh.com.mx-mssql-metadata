USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spIUImportacionEmpleadosMapMini](  
	@dtEmpleados [RH].[dtEmpleadosImportacionMapMini] READONLY  
	,@IDUsuario int
)  
AS  
BEGIN
	declare @tempMessages as table(
		ID int,
		[Message] varchar(500),
		Valid bit
	)

	insert @tempMessages(ID, [Message], Valid)
	values
		(1, 'Datos correctos', 1),
		(2, 'El Nombre del Cliente no Existe', 0),
		(3, 'El Tipo de nomina del Cliente no Existe', 0),
		(4, 'El Primer Nombre del colaboradore es necesario', 0),
		(5, 'El Apellido Paterno del colaboradore es necesario', 0),
		(6, 'El Pais de Nacimiento no Existe', 0),
		(7, 'El Estado de Nacimiento no Existe', 0),
		(8, 'El Municipio de Nacimiento no Existe', 0),
		(9, 'La Fecha de Nacimiento es necesaria', 0),
		(10, 'La Fecha de Nacimiento es necesaria', 0),
		(11, 'El Sexo del colaborador es necesaria', 0),
		(12, 'El Estado Civil del colaborador es necesaria', 0),
		(13, 'La Fecha de Antiguedad del colaborador es necesaria', 0),
		(14, 'La Fecha de Ingreso del colaborador es necesaria', 0),
		(15, 'El tipo de Prestación del colaborador es necesaria', 0),
		(16, 'La Razón Social del colaborador es necesaria', 0),
		(17, 'El Registro Patronal del colaborador es necesaria', 0),
		(18, 'El Salario Diario del colaborador es necesaria', 0),
		(19, 'El Salario Integrado del colaborador es necesaria', 0),
		(20, 'El Email del colaborador es necesaria', 1),
		(21, 'El Departamento del colaborador no coincide', 1),
		(22, 'La Sucursal del colaborador no coincide', 1),
		(23, 'El Puesto del colaborador no coincide', 1),
		(24, 'El Centro de Costo del colaborador no coincide', 1),
		(25, 'El Area del colaborador no coincide', 1),
		(26, 'La Región del colaborador no coincide', 1),
		(27, 'La División del colaborador no coincide', 1),
		(28, 'La Clasificación Corporativa del colaborador no coincide', 1),
		(29, 'La Dirección del colaborador no coincide', 1),
		(30, 'La Escolaridad del colaborador no coincide', 1),
		(31, 'La Institución del colaborador no coincide', 1),
		(32, 'El Tipo de Regimen Fiscal del colaborador no coincide', 1),
		(33, 'La Clave del Colaborador Existe', 0)


	select 
		info.*,
        (select m.[Message] as Message, CAST(m.Valid as bit) as Valid
        from @tempMessages m 
        where ID in (SELECT ITEM from app.split(info.IDMensaje,',')) 
        FOR JSON PATH) as Msg,
		CAST(
		CASE WHEN EXISTS (  (select m.[Valid] as Message
        from @tempMessages m 
        where ID in (SELECT ITEM from app.split(info.IDMensaje,',') )and Valid = 0 )) THEN 0 ELSE 1 END as bit)  as Valid
	from (
		select   
			isnull((Select TOP 1 IDEmpleado from RH.tblEmpleados Where ClaveEmpleado = E.[ClaveEmpleado] ),0)as [IDEmpleado] 
			,E.[ClaveEmpleado]  
			,(
				select top 1 IDCliente,  JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'NombreComercial')) as Descripcion
				from RH.tblCatClientes c with(nolock)
				where JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'NombreComercial')) = E.[Cliente]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			) as [clienteEmpleado] 
			,(
				select  top 1 tn.IDTipoNomina,  tn.Descripcion as Descripcion
				from RH.tblCatClientes c with(nolock)
					inner join Nomina.tblCatTipoNomina tn with(nolock)
						on c.IDCliente = tn.IDCliente
				where JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'NombreComercial')) = E.[Cliente]
					and tn.Descripcion = E.[TipoNomina] 
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			) as [tipoNominaEmpleado]
			,E.[Nombre]   
			,E.[SegundoNombre]  
			,E.[Paterno]   
			,E.[Materno]   
			,cast(isnull(E.[FechaNacimiento],'9999-12-31') as DATE) as [FechaNacimiento]  
			,E.[Sexo]   
			,cast(E.[FechaIngreso] as DATE ) as [FechaIngreso]  
			,cast(E.[FechaIngreso] as DATE) as [FechaAntiguedad]  
			,(
				select  top 1 IDDepartamento, JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion  
				from RH.tblCatDepartamentos with(nolock)
				where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) = E.[Departamento]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			) as [departamentoEmpleado]
			,(
				select  top 1 IDSucursal, Descripcion  
				from RH.tblCatSucursales with(nolock)
				where Descripcion = E.[Sucursal]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			) as [sucursalEmpleado]
			,(
				select  top 1 IDPuesto,  JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
				from RH.tblCatPuestos with(nolock)
				where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) = e.[Puesto]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			) as [puestoEmpleado]
			,(
				select  top 1 IDEmpresa, NombreComercial 
				from RH.tblEmpresa with(nolock)
				where NombreComercial = E.[RazonSocial]
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			) as [empresaEmpleado]
			,E.[CorreoElectronico]
			,IDMensaje =  							
				case when isnull((Select TOP 1 IDEmpleado from RH.tblEmpleados Where ClaveEmpleado = E.[ClaveEmpleado] ),0) <> 0 then '33,' else '' END                            
				+case when isnull((select IDCliente from RH.tblCatClientes with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'NombreComercial')) = E.[Cliente]),0) = 0 then  '2,' else '' END                            
				+case when isnull((select tn.IDTipoNomina
									from RH.tblCatClientes c with(nolock)
										inner join Nomina.tblCatTipoNomina tn with(nolock)
											on c.IDCliente = tn.IDCliente
									where JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'NombreComercial')) = E.[Cliente]
									and tn.Descripcion = E.[TipoNomina] 
								),0) = 0 then '3,' else '' END 
				+case when isnull(E.[Nombre],'') = '' then '4,' else '' END                            
				+case when isnull(E.[Paterno],'') = '' then '5,' else '' END                            
				+case when isnull(E.[FechaNacimiento],'9999-12-31') = '9999-12-31' then '9,'  else '' END 
				+case when isnull(E.[Sexo],'') = '' then '11,' else '' END                           
				+case when isnull(E.[FechaAntiguedad],'9999-12-31') = '9999-12-31' then '13,' else '' END  
				+case when isnull(E.[FechaIngreso],'9999-12-31') = '9999-12-31' then '14,' else '' END  
				+case when isnull(( select  top 1 IDEmpresa from RH.tblEmpresa with(nolock) where NombreComercial = E.[RazonSocial]),0) = 0 then '16,' else '' END                            
				+case when isnull((  select  top 1 IDDepartamento  from RH.tblCatDepartamentos with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) = E.[Departamento]),0) = 0 then '21,' else '' END                              
				+case when isnull(E.[CorreoElectronico],'') = '' then '20,' else '' END                       
				+case when isnull(( select  top 1 IDSucursal  from RH.tblCatSucursales with(nolock) where Descripcion = E.[Sucursal]),0) = 0 then '22,' else '' END                            
				+case when isnull(( select  top 1 IDPuesto from RH.tblCatPuestos with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) = E.[Puesto]),0) = 0 then '23,'  else '' END                           
		from @dtEmpleados E  
		WHERE isnull(E.Nombre,'') <>''   
	) info 
	order by info.ClaveEmpleado
END
GO
