USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/****************************************************************************************************   
** Descripción  : <Procedure para guardar y actualizar la dirección del Empleado>  
** Autor   : <Aneudy Abreu>  
** Email   : <aneudy.abreu@adagio.com.mx>  
** FechaCreacion : <1/1/2018>  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor    Comentario  
------------------- ------------------- ------------------------------------------------------------  
2018-06-18  Jose Rafael Roman Gil Se agrega la ruta de transporte a la direccion del Empleado  
2018-06-20  Aneudy Abreu   Agregé nuevos campos de texto (@Estado,@Municipio y @CodigoPostal)  
2018-07-06  Jose Roman   Se agrega Procedure para proceso de Sincronizacion  
2018-07-09  Aneudy Abreu      Se agregó el parámetro IDUsuario  
***************************************************************************************************/  
CREATE PROCEDURE [RH].[spUIDireccionEmpleado]  
(  
 @IDDireccionEmpleado INT   
    ,@IDEmpleado          INT     
    ,@IDPais              INT     
    ,@IDEstado            INT     
    ,@Estado    varchar(255)   
    ,@IDMunicipio         INT     
    ,@Municipio varchar(255)     
    ,@IDLocalidad         INT     
    ,@Localidad           VARCHAR (255)   
    ,@IDCodigoPostal      INT     
    ,@CodigoPostal varchar(20)    
    ,@IDColonia           INT     
    ,@Colonia             VARCHAR (255)   
    ,@Calle               VARCHAR (MAX)   
    ,@Exterior            VARCHAR (20)   
    ,@Interior            VARCHAR (20)   
    ,@IDRuta              INT     
    ,@FechaIni            DATE    
    ,@FechaFin            DATE   
    ,@IDUsuario   int   
 -- @IDDireccionEmpleado int = 0  
 --,@IDEmpleado   int  
 --,@IDCodigoPostal  int  
 --,@IDEstado    int  
 --,@IDMunicipio   int  
 --,@IDColonia    int  
 --,@IDPais    int  
 --,@IDLocalidad   int  
 --,@Localidad   Varchar(255)  
 --,@Colonia   Varchar(255)  
 --,@Calle    Varchar(MAX)  
 --,@Exterior   Varchar(20)  
 --,@Interior   Varchar(20)  
 --,@IDRuta    int  
 --,@FechaIni   Date  
 --,@FechaFin   Date  
)  
AS  
BEGIN  
    Declare @msj nvarchar(max) ; 
	 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	
	SET @Colonia = UPPER(@Colonia)            
    SET @Calle   = UPPER(@Calle)                       
    SET @Exterior = UPPER(@Exterior)                      
    SET @Interior = UPPER(@Interior)                      
    SET @Localidad = UPPER(@Localidad)                      
	
	 
  
    IF(@IDDireccionEmpleado = 0 or @IDDireccionEmpleado is null)  
    BEGIN  
		if exists(select 1 from RH.tblDireccionEmpleado  
		where IDEmpleado = @IDEmpleado and FechaIni=@FechaIni)  
		begin  
			set @msj= cast(@FechaIni as varchar(10));  
			--raiserror(@msj,16,0);  
			exec [App].[spObtenerError]  
			 @IDUsuario  = @IDUsuario,  
			 @CodigoError ='0302001',  
			 @CustomMessage = @msj  
			return;  
		end;  
  
		INSERT INTO [RH].[tblDireccionEmpleado]( IDEmpleado,IDPais,IDEstado,Estado,IDMunicipio  
		,Municipio,IDLocalidad,Localidad,IDCodigoPostal,CodigoPostal,IDColonia,Colonia,Calle,Exterior,Interior,IDRuta,FechaIni,FechaFin)  
		SELECT   
		 @IDEmpleado  
		,CASE WHEN @IDPais = 0 then null else @IDPais end  
		,CASE WHEN @IDEstado = 0 then null else @IDEstado end  
		,@Estado  
		,CASE WHEN @IDMunicipio = 0 then null else @IDMunicipio end  
		,@Municipio  
		,CASE WHEN @IDLocalidad = 0 then null else @IDLocalidad end  
		,@Localidad  
		,CASE WHEN @IDCodigoPostal = 0 then null else @IDCodigoPostal end   
		,@CodigoPostal  
		,CASE WHEN @IDColonia = 0 then null else @IDColonia end  
		,@Colonia  
		,@Calle  
		,@Exterior  
		,@Interior  
		,CASE WHEN @IDRuta = 0 then null else @IDRuta end  
		,@FechaIni  
		,@FechaFin  
    --INSERT INTO RH.tblDireccionEmpleado(IDEmpleado,IDLocalidad,IDCodigoPostal,IDEstado,IDMunicipio,IDColonia,IDPais,Colonia,Localidad,Calle,Exterior,Interior,IDRuta,FechaIni,FechaFin)  
    --VALUES(@IDEmpleado  
    --,CASE WHEN @IDLocalidad = 0 then null else @IDLocalidad end  
    --,CASE WHEN @IDCodigoPostal = 0 then null else @IDCodigoPostal end  
    --,CASE WHEN @IDEstado = 0 then null else @IDEstado end  
    --,CASE WHEN @IDMunicipio = 0 then null else @IDMunicipio end  
    --,CASE WHEN @IDColonia = 0 then null else @IDColonia end  
    --,CASE WHEN @IDPais = 0 then null else @IDPais end  
    --,@Colonia  
    --,@Localidad  
    --,@Calle,@Exterior,@Interior  
    --,CASE WHEN @IDRuta = 0 then null else @IDRuta end  
    --,@FechaIni,@FechaFin)  
		SET @IDDireccionEmpleado = @@IDENTITY

		
		select @NewJSON = a.JSON from [RH].[tblDireccionEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDireccionEmpleado = @IDDireccionEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblDireccionEmpleado]','[RH].[spUIDireccionEmpleado]','INSERT',@NewJSON,''

    END  
    ELSE  
    BEGIN  
		select @OldJSON = a.JSON from [RH].[tblDireccionEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDireccionEmpleado = @IDDireccionEmpleado

		UPDATE RH.tblDireccionEmpleado  
		SET  
		 IDPais = CASE WHEN @IDPais = 0 then null else @IDPais end  
		,IDEstado = CASE WHEN @IDEstado = 0 then null else @IDEstado end  
		,Estado = @Estado  
		,IDMunicipio = CASE WHEN @IDMunicipio = 0 then null else @IDMunicipio end  
		,Municipio = @Municipio  
		,IDLocalidad = CASE WHEN @IDLocalidad = 0 then null else @IDLocalidad end  
		,Localidad = @Localidad  
		,IDCodigoPostal = CASE WHEN @IDCodigoPostal = 0 then null else @IDCodigoPostal end   
		,CodigoPostal = @CodigoPostal  
		,IDColonia= CASE WHEN @IDColonia = 0 then null else @IDColonia end  
		,Colonia = @Colonia  
		,Calle = @Calle  
		,Exterior = @Exterior  
		,Interior = @Interior  
		,IDRuta = CASE WHEN @IDRuta = 0 then null else @IDRuta end  
		,FechaIni = @FechaIni  
		,FechaFin = @FechaFin  
  
    -- FechaFin = @FechaFin  
    --,FechaIni = @FechaIni  
    --,IDCodigoPostal=CASE WHEN @IDCodigoPostal = 0 then null else @IDCodigoPostal end  
    --,IDEstado   =CASE WHEN @IDEstado = 0 then null else @IDEstado end  
    --,IDMunicipio   =CASE WHEN @IDMunicipio = 0 then null else @IDMunicipio end  
    --,IDColonia   =CASE WHEN @IDColonia = 0 then null else @IDColonia end  
    --,IDPais    =CASE WHEN @IDPais = 0 then null else @IDPais end  
    --,IDLocalidad    =CASE WHEN @IDLocalidad = 0 then null else @IDLocalidad end  
    --,Calle    =@Calle  
    --,Colonia        =@Colonia  
    --,Localidad        =@Localidad  
    --,Exterior   =@Exterior  
    --,Interior   =@Interior  
    --,IDRuta    =CASE WHEN @IDRuta = 0 then null else @IDRuta end  
		WHERE IDEmpleado = @IDEmpleado  
		and IDDireccionEmpleado = @IDDireccionEmpleado  

		select @NewJSON = a.JSON from [RH].[tblDireccionEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDDireccionEmpleado = @IDDireccionEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblDireccionEmpleado]','[RH].[spUIDireccionEmpleado]','UPDATE',@NewJSON,@OldJSON


    END;  
  
    if OBJECT_ID('tempdb..#tblTempHistorial1') is not null  
    drop table #tblTempHistorial1;  
  
    if OBJECT_ID('tempdb..#tblTempHistorial2') is not null  
    drop table #tblTempHistorial2;  
  
    select *, ROW_NUMBER()over(order by FechaIni asc) as [Row]  
    INTO #tblTempHistorial1  
    FROM RH.tblDireccionEmpleado  
    WHERE IDEmpleado = @IDEmpleado  
    order by FechaIni asc  
  
    select   
    t1.IDDireccionEmpleado  
    ,t1.IDEmpleado     
    ,t1.FechaIni  
    ,FechaFin = case when t2.FechaIni is not null then dateadd(day,-1,t2.FechaIni)   
    else '9999-12-31' end   
    INTO #tblTempHistorial2  
    from #tblTempHistorial1 t1  
    left join (select *   
    from #tblTempHistorial1) t2 on t1.[Row] = (t2.[Row]-1)  
  
    update [TARGET]  
    set   
    [TARGET].FechaFin = [SOURCE].FechaFin  
    FROM RH.tblDireccionEmpleado as [TARGET]  
    join #tblTempHistorial2 as [SOURCE] on [TARGET].IDDireccionEmpleado = [SOURCE].IDDireccionEmpleado  
   

  
 declare @tran int 
   set @tran = @@TRANCOUNT
   if(@tran = 0)
   BEGIN
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
   END 
END
GO
