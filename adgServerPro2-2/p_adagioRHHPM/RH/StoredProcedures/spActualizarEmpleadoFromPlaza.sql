USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp actualiza la información de catalogos del colaborador por la configuracion de la plaza.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-03-09
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [RH].[spActualizarEmpleadoFromPlaza]    
    @IDPlaza int,
    @IDEmpleado int,
    @IDUsuario int ,
    @fecha date 
AS
BEGIN
    DECLARE @IDIdioma varchar(225),
    @json VARCHAR(max)
        

    BEGIN TRY
        BEGIN TRAN TransActualizarEmpleadoPlaza
            --SELECT 1/0;-- PROVOCAR EXCEPCIÓN               
            select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

            SELECT @json=Configuraciones
            from rh.tblCatPlazas
            where IDPlaza=@IDPlaza

            declare @dtConfiguraciones as table(
                IDTipoConfiguracionPlaza varchar(100) , 
                Valor varchar(100)
            );

            insert into @dtConfiguraciones (IDTipoConfiguracionPlaza,Valor)
            select 		
                ctcp.IDTipoConfiguracionPlaza        
                , t.Valor                      
            from [RH].[tblCatTiposConfiguracionesPlazas] ctcp with (nolock)				 
            left join (
                SELECT IDTipoConfiguracionPlaza,Valor
                    FROM OPENJSON(@json )
                    WITH (   
                        IDTipoConfiguracionPlaza   varchar(200) '$.IDTipoConfiguracionPlaza' ,                
                        Valor int          '$.Valor'  
                    ) 
            ) as t on t.IDTipoConfiguracionPlaza = ctcp.IDTipoConfiguracionPlaza                
            where ctcp.Disponible=1   AND ctcp.IDTipoConfiguracionPlaza<>'PosicionJefe'
            order by ctcp.Orden

            
            declare @id  VARCHAR(255),
                @idtemp VARCHAR(255)
            --> DEPARTAMENTOS
                select @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'Departamento'
                select @idtemp=IDDepartamento from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;;                
                if @id<> @idtemp and @id is not null 
                begin
                    exec [RH].[spUIDepartamentoEmpleado] @IDEmpleado =@IDEmpleado ,
                        @IDDepartamento =@id,
                        @FechaIni  =@fecha,
                        @FechaFin  =@fecha,
                        @IDUsuario =@IDUsuario
                end
                
            --> SUCURSALES
                select @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'Sucursal'                
                select @idtemp=IDSucursal from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;
                

                if cast(@id as int) != cast(@idtemp as int) and @id is not null 
                begin
                                    exec [RH].[spUISucursalEmpleado] @IDEmpleado =@IDEmpleado ,
                    @IDSucursal =@id,
                    @FechaIni  =@fecha,
                    @FechaFin  =@fecha,
                    @IDUsuario =@IDUsuario   
                end
                
              

            --> PRESTACIONES                
                select @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'Prestaciones'
                select @idtemp=IDTipoPrestacion from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;;                
                if @id<> @idtemp and @id is not null 
                begin
                    exec [RH].[spUIPrestacionEmpleado]  
                        @IDPrestacionEmpleado  = 0  
                        ,@IDEmpleado =@IDEmpleado
                        ,@IDTipoPrestacion =@id
                        ,@FechaIni =@fecha
                        ,@FechaFin =@fecha
                        ,@IDUsuario =@IDUsuario
                end
                
                
            --> RegistroPatronal                
                select @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'RegistroPatronal'
                select @idtemp=IDRegPatronal from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;;                
                if @id<> @idtemp and @id is not null 
                begin
                    exec [RH].[spUIRegPatronalEmpleado]  
                        @IDRegPatronalEmpleado  = 0  
                        ,@IDEmpleado =@IDEmpleado 
                        ,@IDRegPatronal =@id 
                        ,@FechaIni =@fecha
                        ,@FechaFin  =@fecha
                        ,@IDUsuario= @IDUsuario
                end
                
            --> EMPRESA                
                select @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'Empresa'
                select @idtemp=IDEmpresa from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;                

                if @id<> @idtemp and @id is not null 
                begin
                    exec [RH].[spUIEmpresaEmpleado]  
                        @IDEmpresaEmpleado  = 0  
                        ,@IDEmpleado =@IDEmpleado
                        ,@IDEmpresa =@id
                        ,@FechaIni =@fecha
                        ,@FechaFin =@fecha 
                        ,@IDUsuario =@IDUsuario
                end            
                
            --> CentroCosto                
                select @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'CentroCosto'
                select @idtemp=IDCentroCosto from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;;
                if @id<> @idtemp and @id is not null 
                begin
                    exec [RH].[spUICentroCostoEmpleado]  
                        @IDCentroCostoEmpleado  = 0  
                        ,@IDEmpleado=@IDEmpleado  
                        ,@IDCentroCosto=@id
                        ,@FechaIni =@fecha
                        ,@FechaFin =@fecha
                        ,@IDUsuario=@IDUsuario
                end            
                
            --> Area
                select @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'Area'                
                select @idtemp=IDArea from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;;
                if @id<> @idtemp and @id is not null 
                begin                    
                    exec [RH].[spUIAreaEmpleado]  
                        @IDAreaEmpleado  = 0  
                        ,@IDEmpleado =@IDEmpleado  
                        ,@IDArea =@id
                        ,@FechaIni =@fecha
                        ,@FechaFin =@fecha
                        ,@IDUsuario = @IDUsuario
                end
                
            --> DIVISION
                select @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'Division'                
                select @idtemp=IDDivision from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;;
                if @id<> @idtemp and @id is not null 
                begin
                    exec [RH].[spUIDivisionEmpleado]  
                        @IDDivisionEmpleado  = 0  
                        ,@IDEmpleado =@IDEmpleado
                        ,@IDDivision =@id 
                        ,@FechaIni =@fecha
                        ,@FechaFin =@fecha
                        ,@IDUsuario=@IDUsuario
                end            
                
            --> REGION
                select @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'Region'
                select @idtemp=IDRegion from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;;
                if @id<> @idtemp and @id is not null 
                begin
                    exec [RH].[spUIRegionEmpleado]                      
                        @IDRegionEmpleado = 0  
                        ,@IDEmpleado =@IDEmpleado 
                        ,@IDRegion =@id 
                        ,@FechaIni =@fecha
                        ,@FechaFin =@fecha
                        ,@IDUsuario =@IDUsuario                    
                end                                
                
            --> CLASIFICACION CORPORATIVA
                SELECT @id=Valor from @dtConfiguraciones WHERE IDTipoConfiguracionPlaza=  'ClasificacionCorporativa'
                SELECT @idtemp=IDClasificacionCorporativa from rh.tblEmpleadosMaster where  IDEmpleado=@IDEmpleado;;
                if @id<> @idtemp and @id is not null 
                begin
                    exec [RH].[spUIClasificacionCorporativaEmpleado]    
                        @IDClasificacionCorporativaEmpleado  = 0  
                        ,@IDEmpleado =@IDEmpleado
                        ,@IDClasificacionCorporativa =@id
                        ,@FechaIni =@fecha
                        ,@FechaFin =@fecha
                        ,@IDUsuario =@IDUsuario
                end                                
                
                exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado
        COMMIT TRAN TransActualizarEmpleadoPlaza
    END TRY
    BEGIN CATCH    
        ROLLBACK TRAN TransActualizarEmpleadoPlaza         
        EXEC [App].[spObtenerError] @IDUsuario = 1, @CodigoError = '0302007'         
    END CATCH       

END
GO
