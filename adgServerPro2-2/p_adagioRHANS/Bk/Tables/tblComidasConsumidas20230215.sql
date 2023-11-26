USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Bk].[tblComidasConsumidas20230215](
	[IDComidaConsumida] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[Fecha] [datetime] NOT NULL,
	[IDLector] [int] NULL
) ON [PRIMARY]
GO
