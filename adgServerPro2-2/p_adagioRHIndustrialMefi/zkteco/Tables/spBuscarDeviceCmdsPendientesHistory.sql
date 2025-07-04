USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [zkteco].[spBuscarDeviceCmdsPendientesHistory](
	[DevSN] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Executed] [bit] NULL,
	[FechaReg] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [zkteco].[spBuscarDeviceCmdsPendientesHistory] ADD  DEFAULT ((0)) FOR [Executed]
GO
ALTER TABLE [zkteco].[spBuscarDeviceCmdsPendientesHistory] ADD  DEFAULT (getdate()) FOR [FechaReg]
GO
